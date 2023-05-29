package applications

import (
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"

	"github.com/james/monorepo/pulumi_dev_local/pkg/resources"
	"github.com/james/monorepo/pulumi_dev_local/pkg/utils"
)

// DeployTelepresence sets up the Telepresence Helm chart
func DeployTelepresence(ctx *pulumi.Context, provider *kubernetes.Provider) error {
	// Get configuration
	conf := utils.NewConfig(ctx)
	enabled := conf.GetBool("telepresence_enabled", false)

	if !enabled {
		ctx.Log.Info("Telepresence is disabled, skipping deployment", nil)
		return nil
	}

	namespace := "telepresence"

	// Deploy telepresence traffic manager
	_, err := resources.DeployHelmChart(ctx, provider, resources.HelmChartConfig{
		Name:            "telepresence",
		Namespace:       namespace,
		ChartName:       "telepresence",
		RepositoryURL:   "https://app.getambassador.io",
		Version:         "2.14.1",
		CreateNamespace: true,
		Values: map[string]interface{}{
			"replicaCount": 1,
			"image": map[string]interface{}{
				"registry":        "docker.io",
				"repository":      "datawire/telepresence",
				"tag":             "2.14.1",
				"imagePullPolicy": "IfNotPresent",
			},
			"podLabels": map[string]interface{}{
				"app.kubernetes.io/name":    "traffic-manager",
				"app.kubernetes.io/part-of": "telepresence",
			},
			"clientRbac": map[string]interface{}{
				"create": true,
			},
			"agentInjector": map[string]interface{}{
				"enabled": true,
				"webhook": map[string]interface{}{
					"port": 8443,
					"livenessProbe": map[string]interface{}{
						"failureThreshold":    3,
						"initialDelaySeconds": 10,
						"periodSeconds":       5,
						"successThreshold":    1,
						"timeoutSeconds":      1,
					},
					"readinessProbe": map[string]interface{}{
						"failureThreshold":    3,
						"initialDelaySeconds": 10,
						"periodSeconds":       5,
						"successThreshold":    1,
						"timeoutSeconds":      1,
					},
				},
			},
			"resources": map[string]interface{}{
				"limits": map[string]interface{}{
					"cpu":    "100m",
					"memory": "128Mi",
				},
				"requests": map[string]interface{}{
					"cpu":    "50m",
					"memory": "64Mi",
				},
			},
		},
		Wait:    true,
		Timeout: 300,
	})

	if err != nil {
		return err
	}

	// Export Telepresence information
	ctx.Export("telepresenceNamespace", pulumi.String(namespace))

	return nil
}
