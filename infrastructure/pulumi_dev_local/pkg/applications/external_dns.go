package applications

import (
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"

	"github.com/james/monorepo/pulumi_dev_local/pkg/resources"
	"github.com/james/monorepo/pulumi_dev_local/pkg/utils"
)

// DeployExternalDNS sets up external-dns using Helm
func DeployExternalDNS(ctx *pulumi.Context, provider *kubernetes.Provider) error {
	// Get configuration
	conf := utils.NewConfig(ctx)
	enabled := conf.GetBool("external_dns_enabled", false)
	version := conf.GetString("external_dns_version", "1.15.0")

	if !enabled {
		ctx.Log.Info("External DNS is disabled, skipping deployment", nil)
		return nil
	}

	// Create namespace
	namespace := conf.GetString("external_dns:namespace", "external-dns")
	ns, err := resources.CreateK8sNamespace(ctx, provider, resources.K8sNamespaceConfig{
		Name: namespace,
		Labels: map[string]string{
			"app": "external-dns",
		},
	})

	if err != nil {
		return err
	}

	// Get external-secrets configuration
	externalSecretsEnabled := conf.GetBool("external_secrets_enabled", false)

	// Default values for external-dns Helm chart
	values := map[string]interface{}{
		"provider": "cloudflare",
		"env": []interface{}{
			map[string]interface{}{
				"name": "CF_API_TOKEN",
				"valueFrom": map[string]interface{}{
					"secretKeyRef": map[string]interface{}{
						"name": "cf-secret",
						"key":  "cloudflare-api-key",
					},
				},
			},
		},
		"txtOwnerId": "bluecentre-dev",
		"interval":   "30m",
		"sources": []interface{}{
			"istio-gateway",
		},
		// "domainFilters": []interface{}{
		// 	"ipv1337.dev",
		// },
		// "cloudflare": map[string]interface{}{
		// 	"proxied": true,
		// },
	}

	var deps []pulumi.Resource
	deps = append(deps, ns)

	// If external-secrets is enabled, use it to get the Cloudflare API token
	if externalSecretsEnabled {
		// Create an ExternalSecret to fetch Cloudflare API token
		externalSecret, err := resources.CreateK8sManifest(ctx, provider, resources.K8sManifestConfig{
			Name: "cf-external-secret",
			YAML: `apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: cf-external-secret
  namespace: ` + namespace + `
spec:
  refreshInterval: 1h
  secretStoreRef:
    kind: ClusterSecretStore
    name: external-secret-cluster-fake-cloudflare-secrets
  target:
    name: cf-secret
    creationPolicy: Owner
    template:
      metadata:
        labels:
          service: external-dns
        annotations:
          reloader.stakater.com/match: "true"
  data:
  - secretKey: cloudflare-api-key
    remoteRef:
      key: CLOUDFLARE_API_TOKEN
      version: v1
`,
		}, pulumi.DependsOn([]pulumi.Resource{ns}))

		if err != nil {
			return err
		}

		// Configure external-dns to use the API token from the ExternalSecret
		// values["cloudflare"] = map[string]interface{}{
		// 	"apiToken": map[string]interface{}{
		// 		"name": "cf-external-secret",
		// 		"key":  "cloudflare-api-key",
		// 	},
		// 	"proxied": false,
		// }

		deps = append(deps, externalSecret)
	}
	// } else {
	// 	// For local development without external-secrets, use a fake token
	// 	values["cloudflare"] = map[string]interface{}{
	// 		"apiToken": "fake-api-token",
	// 		"proxied":  false,
	// 	}
	// }

	// Deploy external-dns Helm chart
	_, err = resources.DeployHelmChart(ctx, provider, resources.HelmChartConfig{
		Name:            "external-dns",
		Namespace:       namespace,
		ChartName:       "external-dns",
		RepositoryURL:   "https://kubernetes-sigs.github.io/external-dns",
		Version:         version,
		CreateNamespace: false,
		ValuesFile:      "external-dns",
		Values:          values,
		Wait:            true,
		Timeout:         600,
	}, pulumi.DependsOn(deps))

	// Export external-dns information
	ctx.Export("externalDnsNamespace", pulumi.String(namespace))

	return err
}
