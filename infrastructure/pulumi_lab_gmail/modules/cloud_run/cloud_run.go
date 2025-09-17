package cloud_run

import (
	"fmt"
	"os"
	"strings"

	"github.com/pulumi/pulumi-cloudflare/sdk/v5/go/cloudflare"
	"github.com/pulumi/pulumi-gcp/sdk/v7/go/gcp/cloudrun"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi/config"
)

// DeployServiceArgs defines the arguments for deploying a Cloud Run service.
type DeployServiceArgs struct {
	ProjectID    string
	ServiceName  string
	ImageName    string
	Location     string
	CustomDomain string // New field for custom domain
	// Env provides plain environment variables to inject into the Cloud Run container.
	// Values are stored in configuration state as plain strings (not secrets). For secrets,
	// integrate Secret Manager + env var references in a future enhancement.
	Env map[string]string
	// If provided, a Cloudflare Zone ID to create the DNS record in.
	CloudflareZoneID string
	// Whether the Cloudflare record should be proxied (orange cloud). Use false for Cloud Run mapping.
	CloudflareProxied bool
	// Add more arguments as needed, e.g., traffic, env vars, etc.
}

// DeployService deploys a new Google Cloud Run service.
func DeployService(ctx *pulumi.Context, name string, args *DeployServiceArgs, opts ...pulumi.ResourceOption) (*cloudrun.Service, error) {
	// Build environment variable list if provided
	var envVars cloudrun.ServiceTemplateSpecContainerEnvArray
	if len(args.Env) > 0 {
		for k, v := range args.Env {
			kCopy := k
			vCopy := v
			envVars = append(envVars, &cloudrun.ServiceTemplateSpecContainerEnvArgs{
				Name:  pulumi.String(kCopy),
				Value: pulumi.String(vCopy),
			})
		}
	}

	service, err := cloudrun.NewService(ctx, name, &cloudrun.ServiceArgs{
		Project:  pulumi.String(args.ProjectID),
		Location: pulumi.String(args.Location),
		Name:     pulumi.String(args.ServiceName),
		Template: &cloudrun.ServiceTemplateArgs{
			Spec: &cloudrun.ServiceTemplateSpecArgs{
				Containers: cloudrun.ServiceTemplateSpecContainerArray{
					&cloudrun.ServiceTemplateSpecContainerArgs{
						Image: pulumi.String(args.ImageName),
						Envs:  envVars,
					},
				},
			},
		},
	}, opts...) // Pass through the opts here
	if err != nil {
		return nil, err
	}

	// Allow unauthenticated access to the service
	_, err = cloudrun.NewIamMember(ctx, name+"-iam", &cloudrun.IamMemberArgs{
		Project:  pulumi.String(args.ProjectID),
		Location: pulumi.String(args.Location),
		Service:  service.Name,
		Role:     pulumi.String("roles/run.invoker"),
		Member:   pulumi.String("allUsers"),
	}, opts...) // Also pass opts to IAM member
	if err != nil {
		return nil, err
	}

	ctx.Export(name+"URL", service.Statuses.ApplyT(func(statuses []cloudrun.ServiceStatus) (string, error) {
		if len(statuses) > 0 {
			return *statuses[0].Url, nil
		}
		return "", nil
	}).(pulumi.StringOutput))

	// If a custom domain is provided, create a DomainMapping (validation guard later checks DNS config)
	if args.CustomDomain != "" {
		domainMapping, err := cloudrun.NewDomainMapping(ctx, name+"-domain-mapping", &cloudrun.DomainMappingArgs{
			Project:  pulumi.String(args.ProjectID),
			Location: pulumi.String(args.Location),
			Name:     pulumi.String(args.CustomDomain),
			Metadata: &cloudrun.DomainMappingMetadataArgs{
				Namespace: pulumi.String(args.ProjectID),
			},
			Spec: &cloudrun.DomainMappingSpecArgs{
				RouteName: service.Name,
			},
		}, opts...) // Pass through the opts here
		if err != nil {
			return nil, err
		}

		ctx.Export(name+"CustomDomain", domainMapping.Name)

		// Build DNS target dynamically from DomainMapping status if available.
		// Default fallback is ghs.googlehosted.com which works for Cloud Run mappings in many cases.
		dnsTarget := domainMapping.Statuses.ApplyT(func(ss interface{}) (string, error) {
			// ss is expected to be a []interface{} representing statuses
			if ss == nil {
				return "ghs.googlehosted.com", nil
			}
			arr, ok := ss.([]interface{})
			if !ok || len(arr) == 0 {
				return "ghs.googlehosted.com", nil
			}
			first, ok := arr[0].(map[string]interface{})
			if !ok {
				return "ghs.googlehosted.com", nil
			}
			// Try 'resourceRecords'
			if rrsRaw, ok := first["resourceRecords"]; ok {
				if rrs, ok := rrsRaw.([]interface{}); ok && len(rrs) > 0 {
					rr0, ok := rrs[0].(map[string]interface{})
					if ok {
						// Try rrdata or rrdatas
						if v, ok := rr0["rrdata"]; ok {
							if s, ok := v.(string); ok && s != "" {
								return s, nil
							}
						}
						if v, ok := rr0["rrdatas"]; ok {
							if slice, ok := v.([]interface{}); ok && len(slice) > 0 {
								if s, ok := slice[0].(string); ok && s != "" {
									return s, nil
								}
							}
						}
					}
				}
			}
			return "ghs.googlehosted.com", nil
		}).(pulumi.StringOutput)

		// Export the DNS target so users can see what to point their CNAME to.
		ctx.Export(name+"DomainMappingTarget", dnsTarget)

		// Determine cloudflare zone id/name to use. If the caller didn't set it on args,
		// fall back to Pulumi config `cloudflare:zoneId`.
		cfg := config.New(ctx, "")
		cfCfg := config.New(ctx, "cloudflare")
		projCfg := config.New(ctx, "pulumi_lab_gmail")
		zoneConfigured := args.CloudflareZoneID
		if zoneConfigured == "" {
			zoneConfigured = cfCfg.Get("zoneId")
		}
		if zoneConfigured == "" {
			zoneConfigured = cfg.Get("cloudflare:zoneId")
		}
		if zoneConfigured == "" {
			zoneConfigured = projCfg.Get("cloudflare:zoneId")
		}
		// Allow using zoneName alone; will resolve to ID later
		if zoneConfigured == "" {
			zoneConfigured = cfCfg.Get("zoneName")
		}

		// If user specified a custom domain but provided neither a zone id/name nor configured any Cloudflare token (config nor env), we still allow the DomainMapping but skip DNS.
		// Validation Guard: If they provided a custom domain AND set a Cloudflare apiToken (meaning they intend automation) but omitted zone info, fail fast to avoid silent misconfig.
		apiTokenCheck := cfCfg.Get("apiToken")
		if apiTokenCheck == "" {
			apiTokenCheck = cfg.Get("cloudflare:apiToken")
		}
		if apiTokenCheck == "" {
			apiTokenCheck = projCfg.Get("cloudflare:apiToken")
		}
		if apiTokenCheck == "" {
			apiTokenCheck = os.Getenv("CLOUDFLARE_API_TOKEN")
		}
		if apiTokenCheck != "" && zoneConfigured == "" {
			return nil, fmt.Errorf("customDomain specified (%s) and Cloudflare API token configured but no zoneId or zoneName provided; set cloudflare:zoneId or cloudflare:zoneName", args.CustomDomain)
		}

		// Create DNS record only if zone information is available
		if zoneConfigured != "" {
			// Compute the record name. Prefer a zone-relative name when possible so
			// Cloudflare doesn't end up creating a full-FQDN that can be awkward to update.
			recordName := strings.TrimSuffix(args.CustomDomain, ".")

			// Optionally create a Cloudflare provider using Pulumi config `cloudflare:apiToken`.
			// If not provided, the Cloudflare provider will fall back to environment variables.
			apiToken := cfCfg.Get("apiToken")
			if apiToken == "" {
				apiToken = cfg.Get("cloudflare:apiToken")
			}
			if apiToken == "" {
				apiToken = projCfg.Get("cloudflare:apiToken")
			}
			// Optional: the Cloudflare zone name (e.g. "ipv1337.dev"). If provided we will strip it
			// from the full custom domain to build a zone-relative record name. This avoids mismatches
			// when users supply a zone for the parent domain.
			zoneName := cfCfg.Get("zoneName")
			if zoneName == "" {
				zoneName = cfg.Get("cloudflare:zoneName")
			}
			if zoneName == "" {
				zoneName = projCfg.Get("cloudflare:zoneName")
			}
			if zoneName != "" {
				// Normalize and trim any trailing dots from zoneName and recordName
				zoneName = strings.TrimSuffix(zoneName, ".")
				if strings.HasSuffix(recordName, "."+zoneName) {
					recordName = strings.TrimSuffix(recordName, "."+zoneName)
				}
			}

			var cfProvider *cloudflare.Provider
			// Allow token in Pulumi config or environment
			if apiToken == "" {
				apiToken = os.Getenv("CLOUDFLARE_API_TOKEN")
			}
			if apiToken != "" {
				cfProvider, err = cloudflare.NewProvider(ctx, name+"-cf-provider", &cloudflare.ProviderArgs{
					ApiToken: pulumi.String(apiToken),
				}, opts...)
				if err != nil {
					return nil, err
				}
			}

			// Build provider invoke options so we can use the same provider for invocations like LookupZone
			var invokeOpts []pulumi.InvokeOption
			if cfProvider != nil {
				invokeOpts = append(invokeOpts, pulumi.Provider(cfProvider))
			}

			// Resolve zone ID: if the provided Cloudflare Zone ID/name looks like a domain name
			// (e.g. "ipv1337.dev"), attempt to look up the actual zone ID via the provider.
			zoneIdValue := zoneConfigured
			if strings.Contains(zoneIdValue, ".") {
				// Try to resolve by name
				lookup, lookupErr := cloudflare.LookupZone(ctx, &cloudflare.LookupZoneArgs{
					Name: &zoneIdValue,
				}, invokeOpts...)
				if lookupErr != nil {
					// Return the error so the user can see the lookup problem
					return nil, lookupErr
				}
				if lookup != nil && lookup.Id != "" {
					zoneIdValue = lookup.Id
				}
			}

			// Build record args using dynamic dnsTarget value and resolved zone id
			recArgs := &cloudflare.RecordArgs{
				ZoneId:  pulumi.String(zoneIdValue),
				Name:    pulumi.String(recordName),
				Type:    pulumi.String("CNAME"),
				Value:   dnsTarget,
				Ttl:     pulumi.Int(3600),
				Proxied: pulumi.Bool(args.CloudflareProxied),
			}

			// Export essential DNS outputs
			ctx.Export(name+"CloudflareZoneId", pulumi.String(zoneIdValue))
			ctx.Export(name+"CloudflareRecordName", pulumi.String(recordName))

			// Attach provider if we created one
			var recOpts []pulumi.ResourceOption
			if cfProvider != nil {
				recOpts = append(recOpts, pulumi.Provider(cfProvider))
			}

			// combine opts with recOpts and ensure Cloudflare record depends on DomainMapping
			combinedOpts := make([]pulumi.ResourceOption, 0, len(opts)+len(recOpts)+1)
			combinedOpts = append(combinedOpts, opts...)
			combinedOpts = append(combinedOpts, recOpts...)
			// Ensure the record is created after the DomainMapping resource exists
			combinedOpts = append(combinedOpts, pulumi.DependsOn([]pulumi.Resource{domainMapping}))

			_, err := cloudflare.NewRecord(ctx, name+"-cf-record", recArgs, combinedOpts...)
			if err != nil {
				return nil, err
			}
		}
	}

	return service, nil
}
