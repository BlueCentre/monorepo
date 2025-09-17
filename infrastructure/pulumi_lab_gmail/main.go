package main

import (
	"encoding/json"
	"fmt"

	"github.com/pulumi/pulumi-gcp/sdk/v7/go/gcp"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi/config"

	"github.com/pulumi/pulumi_lab_gmail/modules/cloud_build"
	"github.com/pulumi/pulumi_lab_gmail/modules/cloud_run"
	"github.com/pulumi/pulumi_lab_gmail/modules/iam"
	"github.com/pulumi/pulumi_lab_gmail/modules/project_api_services"
	"github.com/pulumi/pulumi_lab_gmail/modules/service_accounts"
	"github.com/pulumi/pulumi_lab_gmail/modules/storage"
)

const (
	projectID = "personal-llc"
	userEmail = "james.nguyen@gmail.com" // Replace with your actual email
	gcpRegion = "us-central1"            // Example region, adjust as needed
)

func main() {
	pulumi.Run(func(ctx *pulumi.Context) error {
		// Create a GCP provider instance, explicitly targeting the 'personal-llc' project.
		_, err := gcp.NewProvider(ctx, "gcp-provider", &gcp.ProviderArgs{
			Project: pulumi.String(projectID),
		})
		if err != nil {
			return err
		}

		// 1. Enable required API services
		enabledAPIServices, err := project_api_services.EnableAPIServices(ctx, "personal-llc-apis", &project_api_services.EnableAPIServicesArgs{
			ProjectID: projectID,
			Services: []string{
				"cloudapis.googleapis.com",
				"compute.googleapis.com",
				"iam.googleapis.com",
				"cloudbuild.googleapis.com",
				"artifactregistry.googleapis.com",
				"run.googleapis.com",
				"storage.googleapis.com", // Required for the storage bucket
			},
		})
		if err != nil {
			return err
		}

		// 2. Create a Cloud Storage bucket using the storage module.
		_, err = storage.CreateBucket(ctx, "personal-llc-bucket", &storage.CreateBucketArgs{
			ProjectID:  projectID,
			NamePrefix: "personal-llc",
			Location:   "US", // Buckets are global, but location can be specified for data residency
		})
		if err != nil {
			return err
		}

		// 3. Create a service account and grant roles
		_, err = service_accounts.CreateServiceAccount(ctx, "personal-llc-sa", &service_accounts.CreateServiceAccountArgs{
			ProjectID:   projectID,
			AccountID:   "personal-llc-builder",
			DisplayName: "Personal LLC Builder Service Account",
			Roles: []string{
				"roles/editor", // Grant editor role for broad access for prototyping
			},
		})
		if err != nil {
			return err
		}

		// 4. Grant IAM roles to the user
		err = iam.GrantIAMRole(ctx, "personal-llc-viewer", &iam.GrantIAMRoleArgs{
			ProjectID: projectID,
			Member:    "user:" + userEmail,
			Role:      "roles/viewer", // Grant viewer role to your personal email
		})
		if err != nil {
			return err
		}

		// 5. Configure Cloud Build (placeholder for now, will write cloudbuild.yaml directly)
		err = cloud_build.ConfigureCloudBuild(ctx, "personal-llc-cloudbuild", &cloud_build.CloudBuildArgs{
			ProjectID: projectID,
			// RepoURL: "https://github.com/your-repo/your-project", // Uncomment and set if using triggers
		})
		if err != nil {
			return err
		}

		// 6. Deploy a Cloud Run service, explicitly depending on the Cloud Run API being enabled.
		// Provide a CustomDomain so the service will be mapped to my-first-service.run.ipv1337.dev
		// Read Cloudflare zone ID and proxied flag from Pulumi config (optional)
		pulCfg := config.New(ctx, "")
		// Also try project-scoped config for pulumi_lab_gmail
		projCfg := config.New(ctx, "pulumi_lab_gmail")
		cfZone := pulCfg.Get("cloudflare:zoneId")
		if cfZone == "" {
			cfZone = projCfg.Get("cloudflare:zoneId")
		}
		cfProxied, _ := pulCfg.TryBool("cloudflare:proxied")
		customDomain := pulCfg.Get("customDomain")

		// (Removed verbose debug exports; rely on module outputs.)

		deployArgs := &cloud_run.DeployServiceArgs{
			ProjectID:         projectID,
			ServiceName:       "hello",
			ImageName:         "gcr.io/cloudrun/hello", // Example image
			Location:          gcpRegion,
			CloudflareZoneID:  cfZone,
			CloudflareProxied: cfProxied,
		}
		if customDomain != "" {
			deployArgs.CustomDomain = customDomain
		}

		_, err = cloud_run.DeployService(ctx, "personal-llc-cloudrun", deployArgs, pulumi.DependsOn([]pulumi.Resource{enabledAPIServices["run.googleapis.com"]}))
		if err != nil {
			return err
		}

		// Multi-service deployment pattern: optional config key "multiServices" containing JSON array.
		// Example value:
		// [
		//   {"name":"api","image":"gcr.io/cloudrun/hello","customDomain":"api.run.ipv1337.dev"},
		//   {"name":"worker","image":"gcr.io/cloudrun/hello"}
		// ]
		msRaw := pulCfg.Get("multiServices")
		if msRaw != "" {
			var svcDefs []struct {
				Name         string            `json:"name"`
				Image        string            `json:"image"`
				CustomDomain string            `json:"customDomain"`
				Region       string            `json:"region"`
				Env          map[string]string `json:"env"`
			}
			if err := json.Unmarshal([]byte(msRaw), &svcDefs); err != nil {
				return fmt.Errorf("failed to parse multiServices JSON: %w", err)
			}
			for _, def := range svcDefs {
				if def.Name == "" || def.Image == "" {
					return fmt.Errorf("multiServices entries must include at least 'name' and 'image'")
				}
				region := def.Region
				if region == "" {
					region = gcpRegion
				}
				msArgs := &cloud_run.DeployServiceArgs{
					ProjectID:         projectID,
					ServiceName:       def.Name,
					ImageName:         def.Image,
					Location:          region,
					CloudflareZoneID:  cfZone,
					CloudflareProxied: cfProxied,
					Env:               def.Env,
				}
				if def.CustomDomain != "" {
					msArgs.CustomDomain = def.CustomDomain
				}
				// Resource name prefix ensures uniqueness per service definition.
				_, err := cloud_run.DeployService(ctx, fmt.Sprintf("personal-llc-%s-cloudrun", def.Name), msArgs, pulumi.DependsOn([]pulumi.Resource{enabledAPIServices["run.googleapis.com"]}))
				if err != nil {
					return err
				}
			}
		}

		return nil
	})
}
