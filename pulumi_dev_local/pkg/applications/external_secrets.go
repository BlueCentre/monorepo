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
	datadogApiKey := conf.GetString("datadog_api_key", "REPLACE_WITH_DATADOG_API_KEY")
	datadogAppKey := conf.GetString("datadog_app_key", "REPLACE_WITH_DATADOG_APP_KEY")

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
		ValuesFile:      "external-secrets",
		Values: map[string]interface{}{
			"webhook": map[string]interface{}{
				"create": false,
			},
			"certController": map[string]interface{}{
				"create": false,
			},
		},
		Wait:          true,
		Timeout:       600,
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

	// Create a fake secret store for Cloudflare using the dependent provider
	externalDNS := conf.GetBool("external_dns_enabled", false)
	if externalDNS {
		_, err = resources.CreateK8sManifest(ctx, esProvider, resources.K8sManifestConfig{
			Name: "external-secrets-fake-cloudflare-secret-store",
			YAML: `apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: external-secret-cluster-fake-cloudflare-secrets
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
			return fmt.Errorf("failed to create fake cloudflare secret store: %v", err)
		}
	}

	// Create a fake secret store for Datadog using the dependent provider
	// Only created when datadog_enabled is true
	datadogEnabled := conf.GetBool("datadog_enabled", false)
	if datadogEnabled {
		_, err = resources.CreateK8sManifest(ctx, esProvider, resources.K8sManifestConfig{
			Name: "external-secrets-fake-datadog-secret-store",
			YAML: `apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: external-secret-cluster-fake-datadog-secrets
  namespace: external-secrets
spec:
  provider:
    fake:
      data:
      - key: "DATADOG_API_KEY"
        value: "` + datadogApiKey + `"
        version: "v1"
      - key: "DATADOG_APP_KEY"
        value: "` + datadogAppKey + `"
        version: "v1"
      - key: "token"
        value: "` + datadogApiKey + `"
        version: "v1"
`,
		})
		if err != nil {
			return fmt.Errorf("failed to create fake datadog secret store: %v", err)
		}
	}

	// Export External Secrets information
	ctx.Export("externalSecretsNamespace", pulumi.String(namespace))

	return err
}
