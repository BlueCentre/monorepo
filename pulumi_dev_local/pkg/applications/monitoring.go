package applications

import (
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"

	"github.com/james/monorepo/pulumi_dev_local/pkg/resources"
	"github.com/james/monorepo/pulumi_dev_local/pkg/utils"
)

// DeployMonitoringStack sets up Prometheus and Grafana
func DeployMonitoringStack(ctx *pulumi.Context, provider *kubernetes.Provider) error {
	// Get configuration
	conf := utils.NewConfig(ctx)
	enabled := conf.GetBool("monitoring_enabled", false)

	if !enabled {
		ctx.Log.Info("Monitoring stack is disabled, skipping deployment", nil)
		return nil
	}

	// Create namespace if not exists
	namespace := conf.GetString("monitoring:namespace", "monitoring")
	ns, err := resources.CreateK8sNamespace(ctx, provider, resources.K8sNamespaceConfig{
		Name: namespace,
	})

	if err != nil {
		return err
	}

	// Deploy Prometheus with CRD management approach
	prometheus, err := resources.DeployHelmChart(ctx, provider, resources.HelmChartConfig{
		Name:            "prometheus",
		Namespace:       namespace,
		ChartName:       "prometheus",
		RepositoryURL:   "https://prometheus-community.github.io/helm-charts",
		Version:         "22.6.7",
		CreateNamespace: false,
		Values: map[string]interface{}{
			"server": map[string]interface{}{
				"persistentVolume": map[string]interface{}{
					"enabled": false,
				},
			},
			"alertmanager": map[string]interface{}{
				"persistentVolume": map[string]interface{}{
					"enabled": false,
				},
			},
		},
		Wait:    true,
		Timeout: 300,
		// Prometheus has CRDs that need management
		CleanupCRDs:   true,
		CRDsToCleanup: []string{},
	}, pulumi.DependsOn([]pulumi.Resource{ns}))

	if err != nil {
		return err
	}

	// Deploy Grafana with CRD management approach
	_, err = resources.DeployHelmChart(ctx, provider, resources.HelmChartConfig{
		Name:            "grafana",
		Namespace:       namespace,
		ChartName:       "grafana",
		RepositoryURL:   "https://grafana.github.io/helm-charts",
		Version:         "6.58.9",
		CreateNamespace: false,
		Values: map[string]interface{}{
			"persistence": map[string]interface{}{
				"enabled": false,
			},
			"service": map[string]interface{}{
				"type": "ClusterIP",
			},
			"datasources": map[string]interface{}{
				"datasources.yaml": map[string]interface{}{
					"apiVersion": 1,
					"datasources": []interface{}{
						map[string]interface{}{
							"name":      "Prometheus",
							"type":      "prometheus",
							"url":       "http://prometheus-server." + namespace + ".svc.cluster.local",
							"access":    "proxy",
							"isDefault": true,
						},
					},
				},
			},
		},
		Wait:    true,
		Timeout: 300,
		// Grafana has no CRDs that need management
		CleanupCRDs:   false,
		CRDsToCleanup: []string{},
	}, pulumi.DependsOn([]pulumi.Resource{prometheus}))

	// Export monitoring information
	ctx.Export("monitoringNamespace", pulumi.String(namespace))
	ctx.Export("prometheusUrl", pulumi.String("http://prometheus-server."+namespace+".svc.cluster.local"))
	ctx.Export("grafanaUrl", pulumi.String("http://grafana."+namespace+".svc.cluster.local"))

	return err
}
