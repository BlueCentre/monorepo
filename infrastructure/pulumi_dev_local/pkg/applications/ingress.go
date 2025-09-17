package applications

import (
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"

	"github.com/james/monorepo/pulumi_dev_local/pkg/resources"
	"github.com/james/monorepo/pulumi_dev_local/pkg/utils"
)

// DeployIngressController deploys the NGINX ingress controller
func DeployIngressController(ctx *pulumi.Context, provider *kubernetes.Provider) error {
	// Get configuration
	conf := utils.NewConfig(ctx)
	enabled := conf.GetBool("ingress_controller_enabled", true)

	if !enabled {
		ctx.Log.Info("Ingress controller is disabled, skipping deployment", nil)
		return nil
	}

	// Create namespace
	namespace := conf.GetString("ingress:namespace", "ingress-nginx")
	ns, err := resources.CreateK8sNamespace(ctx, provider, resources.K8sNamespaceConfig{
		Name: namespace,
	})

	if err != nil {
		return err
	}

	// Deploy NGINX Ingress Controller with CRD management
	_, err = resources.DeployHelmChart(ctx, provider, resources.HelmChartConfig{
		Name:            "ingress-nginx",
		Namespace:       namespace,
		ChartName:       "ingress-nginx",
		RepositoryURL:   "https://kubernetes.github.io/ingress-nginx",
		Version:         "4.7.1",
		CreateNamespace: false,
		Values: map[string]interface{}{
			"controller": map[string]interface{}{
				"service": map[string]interface{}{
					"type": "ClusterIP",
				},
				"resources": map[string]interface{}{
					"requests": map[string]interface{}{
						"cpu":    "100m",
						"memory": "90Mi",
					},
				},
			},
		},
		Wait:        true,
		Timeout:     300,
		CleanupCRDs: true,
		CRDsToCleanup: []string{
			"ingressclassparams.networking.k8s.io",
		},
	}, pulumi.DependsOn([]pulumi.Resource{ns}))

	// Export ingress controller information
	ctx.Export("ingressNamespace", pulumi.String(namespace))

	return err
}
