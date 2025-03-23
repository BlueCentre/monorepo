package applications

import (
	"fmt"

	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"

	"github.com/james/monorepo/pulumi_dev_local/pkg/resources"
	"github.com/james/monorepo/pulumi_dev_local/pkg/utils"
)

// ExternalSecretsCRDs is a list of all external-secrets CRDs
var ExternalSecretsCRDs = []string{
	"clustersecretstores.external-secrets.io",
	"externalsecrets.external-secrets.io",
	"secretstores.external-secrets.io",
	"clusterexternalsecrets.external-secrets.io",
	"pushsecrets.external-secrets.io",
	"fakes.generators.external-secrets.io",
}

// ExternalSecretsWebhooks is a list of all external-secrets webhooks
var ExternalSecretsWebhooks = []string{
	"externalsecret-validate",
	"secretstore-validate",
}

// DeployExternalSecrets sets up the external-secrets operator
func DeployExternalSecrets(ctx *pulumi.Context, provider *kubernetes.Provider) error {
	// Get configuration
	conf := utils.NewConfig(ctx)
	enabled := conf.GetBool("external_secrets_enabled", false)
	version := conf.GetString("external_secrets_version", "0.14.4")
	cloudflareApiToken := conf.GetString("cloudflare_api_token", "REPLACE_WITH_CLOUDFLARE_API_TOKEN")

	if !enabled {
		ctx.Log.Info("External Secrets is disabled, skipping deployment", nil)
		return nil
	}

	// Create namespace
	namespace := conf.GetString("external_secrets:namespace", "external-secrets")
	ns, err := resources.CreateK8sNamespace(ctx, provider, resources.K8sNamespaceConfig{
		Name: namespace,
	})

	if err != nil {
		return err
	}

	// Deploy External Secrets with CRD management
	externalSecrets, err := resources.DeployHelmChart(ctx, provider, resources.HelmChartConfig{
		Name:            "external-secrets",
		Namespace:       namespace,
		ChartName:       "external-secrets",
		RepositoryURL:   "https://charts.external-secrets.io",
		Version:         version,
		CreateNamespace: false,
		Values: map[string]interface{}{
			"installCRDs": true,
			"global": map[string]interface{}{
				"leaderElection": map[string]interface{}{
					"namespace": namespace,
				},
			},
			"podDisruptionBudget": map[string]interface{}{
				"enabled":      false,
				"minAvailable": 1,
			},
			"webhook": map[string]interface{}{
				"create": false,
			},
			"certController": map[string]interface{}{
				"create": false,
			},
		},
		Wait:          false,
		Timeout:       300,
		CleanupCRDs:   false,
		CRDsToCleanup: ExternalSecretsCRDs,
	}, pulumi.DependsOn([]pulumi.Resource{ns}))

	if err != nil {
		return err
	}

	// Create a provider that depends on the external-secrets chart
	esProvider, err := kubernetes.NewProvider(ctx, "external-secrets-provider", &kubernetes.ProviderArgs{
		// Your provider configuration
	}, pulumi.DependsOn([]pulumi.Resource{externalSecrets}))
	if err != nil {
		return err
	}

	// Create a fake secret store for testing using the dependent provider
	_, err = resources.CreateK8sManifest(ctx, esProvider, resources.K8sManifestConfig{
		Name: "external-secrets-fake-secret-store",
		YAML: `apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: external-secret-cluster-fake-secrets
  namespace: external-secrets
spec:
  provider:
    fake:
      data:
      - key: "CLOUDFLARE_API_TOKEN"
        value: "` + cloudflareApiToken + `"
        version: "v1"
`,
	})
	if err != nil {
		return fmt.Errorf("failed to create fake secret store: %v", err)
	}

	// Export External Secrets information
	ctx.Export("externalSecretsNamespace", pulumi.String(namespace))

	return err
}
