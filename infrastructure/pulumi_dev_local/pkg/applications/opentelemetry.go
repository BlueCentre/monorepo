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
	version := conf.GetString("opentelemetry_version", "0.79.0")

	// Create namespace
	namespace := conf.GetString("opentelemetry:namespace", "opentelemetry")

	// List of OpenTelemetry CRDs to clean up
	otelCRDs := []string{
		"opentelemetrycollectors.opentelemetry.io",
		"instrumentations.opentelemetry.io",
	}

	// Deploy OpenTelemetry Operator with CRD management
	// Add certManagerRelease as a dependency to ensure cert-manager is installed first
	// dependencyResources := []pulumi.Resource{ns}
	dependencyResources := []pulumi.Resource{}
	if certManagerRelease != nil {
		dependencyResources = append(dependencyResources, certManagerRelease)
	}

	otelOperator, err := resources.DeployHelmChart(ctx, provider, resources.HelmChartConfig{
		Name:            "opentelemetry-operator",
		Namespace:       namespace,
		ChartName:       "opentelemetry-operator",
		RepositoryURL:   "https://open-telemetry.github.io/opentelemetry-helm-charts",
		Version:         version,
		CreateNamespace: true,
		ValuesFile:      "opentelemetry-operator",
		Wait:            true, // Set to true to wait for completion
		Timeout:         600,
		CleanupCRDs:     false,
		CRDsToCleanup:   otelCRDs,
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
		ValuesFile:      "opentelemetry-collector",
		Wait:            true,
		Timeout:         600,
		CleanupCRDs:     false,
		CRDsToCleanup:   otelCRDs,
	}, pulumi.DependsOn([]pulumi.Resource{otelOperator}))

	// Export OpenTelemetry information
	ctx.Export("opentelemetryNamespace", pulumi.String(namespace))

	return err
}
