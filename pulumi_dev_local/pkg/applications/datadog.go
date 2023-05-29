package applications

import (
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"

	"github.com/james/monorepo/pulumi_dev_local/pkg/resources"
	"github.com/james/monorepo/pulumi_dev_local/pkg/utils"
)

// DeployDatadog installs Datadog agent
func DeployDatadog(ctx *pulumi.Context, provider *kubernetes.Provider) (pulumi.Resource, error) {
	// Get configuration
	conf := utils.NewConfig(ctx)
	version := conf.GetString("datadog_version", "3.74.1")
	namespace := conf.GetString("datadog_namespace", "datadog")

	// Deploy Datadog using the common function
	datadog, err := resources.DeployHelmChart(ctx, provider, resources.HelmChartConfig{
		Name:            "datadog",
		Namespace:       namespace,
		ChartName:       conf.GetString("datadog:chart_name", "datadog"),
		RepositoryURL:   conf.GetString("datadog:repository_url", "https://helm.datadoghq.com"),
		Version:         version,
		CreateNamespace: false, // We created it already above
		ValuesFile:      "datadog",
		Values: map[string]interface{}{
			"datadog": map[string]interface{}{
				"tags": []string{
					"tenant:monorepo",
					"owner:ipv1337",
					"env:dev",
				},
				"logs": map[string]interface{}{
					"enabled":                true,
					"containerCollectAll":    true,
					"autoMultiLineDetection": true,
				},
				"apm": map[string]interface{}{
					"portEnabled": true,
				},
			},
			"clusterAgent": map[string]interface{}{
				"enabled": true,
				"admissionController": map[string]interface{}{
					"enabled": true,
				},
			},
		},
		Wait:        true,
		Timeout:     600,
		CleanupCRDs: false,
	})

	if err != nil {
		return nil, err
	}

	// Create the external secret for Datadog if external-secrets is enabled
	externalSecretsEnabled := conf.GetBool("external_secrets_enabled", false)
	if externalSecretsEnabled {
		// Create a Kubernetes External Secret manifest for Datadog
		_, err = resources.CreateK8sManifest(ctx, provider, resources.K8sManifestConfig{
			Name: "datadog-external-secrets",
			YAML: `apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: datadog-external-secrets
  namespace: datadog
spec:
  refreshInterval: 1h
  secretStoreRef:
    kind: ClusterSecretStore
    name: external-secret-cluster-fake-datadog-secrets
    # name: external-secret-cluster-lab-secrets # NOTE: This is for the lab environment in GCP
  target:
    creationPolicy: Owner
    name: datadog
  data:
  - secretKey: token
    remoteRef:
      key: DATADOG_API_KEY
      version: v1
  - secretKey: api-key
    remoteRef:
      key: DATADOG_API_KEY
      version: v1
  - secretKey: app-key
    remoteRef:
      key: DATADOG_APP_KEY
      version: v1
`,
		}, pulumi.DependsOn([]pulumi.Resource{datadog}))

		if err != nil {
			return nil, err
		}
	}

	// Export Datadog information
	ctx.Export("datadogNamespace", pulumi.String(namespace))

	return datadog, nil
}
