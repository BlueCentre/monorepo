package applications

import (
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"

	"github.com/james/monorepo/pulumi_dev_local/pkg/resources"
	"github.com/james/monorepo/pulumi_dev_local/pkg/utils"
)

// DeployOpenTelemetry deploys the OpenTelemetry Operator and Collector
func DeployOpenTelemetry(ctx *pulumi.Context, provider *kubernetes.Provider, certManagerRelease pulumi.Resource) error {
	// Get configuration
	conf := utils.NewConfig(ctx)
	enabled := conf.GetBool("opentelemetry_enabled", false)
	version := conf.GetString("opentelemetry_version", "0.79.0")

	if !enabled {
		ctx.Log.Info("OpenTelemetry is disabled, skipping deployment", nil)
		return nil
	}

	// Create namespace
	namespace := conf.GetString("opentelemetry:namespace", "opentelemetry")
	ns, err := resources.CreateK8sNamespace(ctx, provider, resources.K8sNamespaceConfig{
		Name: namespace,
	})

	if err != nil {
		return err
	}

	// List of OpenTelemetry CRDs to clean up
	otelCRDs := []string{
		"opentelemetrycollectors.opentelemetry.io",
		"instrumentations.opentelemetry.io",
	}

	// Deploy OpenTelemetry Operator with CRD management
	// Add certManagerRelease as a dependency to ensure cert-manager is installed first
	dependencyResources := []pulumi.Resource{ns}
	if certManagerRelease != nil {
		dependencyResources = append(dependencyResources, certManagerRelease)
	}

	otelOperator, err := resources.DeployHelmChart(ctx, provider, resources.HelmChartConfig{
		Name:            "opentelemetry-operator",
		Namespace:       namespace,
		ChartName:       "opentelemetry-operator",
		RepositoryURL:   "https://open-telemetry.github.io/opentelemetry-helm-charts",
		Version:         version,
		CreateNamespace: false,
		Values: map[string]interface{}{
			"crds": map[string]interface{}{
				"create": true,
			},
			"manager": map[string]interface{}{
				"collectorImage": map[string]interface{}{
					"repository": "otel/opentelemetry-collector-k8s",
				},
				"leaderElection": map[string]interface{}{
					"enabled": true,
				},
			},
			"admissionWebhooks": map[string]interface{}{
				"create": true,
				"certManager": map[string]interface{}{
					"enabled":                true,
					"issuerRef":              map[string]interface{}{}, // TODO: Update issuerRef to use selfsigned-issuer from cert-manager
					"certificateAnnotations": map[string]interface{}{},
					"issuerAnnotations":      map[string]interface{}{},
					"duration":               "",
					"renewBefore":            "",
				},
				"autoGenerateCert": map[string]interface{}{
					"enabled":        true,
					"recreate":       true,
					"certPeriodDays": 365,
				},
			},
		},
		Wait:          true, // Set to true to wait for completion
		Timeout:       300,
		CleanupCRDs:   false,
		CRDsToCleanup: otelCRDs,
	}, pulumi.DependsOn(dependencyResources))

	if err != nil {
		return err
	}

	// Deploy OpenTelemetry Collector with CRD management
	_, err = resources.DeployHelmChart(ctx, provider, resources.HelmChartConfig{
		Name:            "opentelemetry-collector",
		Namespace:       namespace,
		ChartName:       "opentelemetry-collector",
		RepositoryURL:   "https://open-telemetry.github.io/opentelemetry-helm-charts",
		Version:         version,
		CreateNamespace: false,
		Values: map[string]interface{}{
			"mode":         "deployment",
			"replicaCount": 1,
			"presets": map[string]interface{}{
				"clusterMetrics": map[string]interface{}{
					"enabled": true,
				},
			},
		},
		Wait:          false,
		Timeout:       300,
		CleanupCRDs:   false,
		CRDsToCleanup: otelCRDs,
	}, pulumi.DependsOn([]pulumi.Resource{otelOperator}))

	// Export OpenTelemetry information
	ctx.Export("opentelemetryNamespace", pulumi.String(namespace))

	return err
}
