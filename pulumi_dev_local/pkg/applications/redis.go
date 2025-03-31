package applications

import (
	"github.com/james/monorepo/pulumi_dev_local/pkg/resources"
	"github.com/james/monorepo/pulumi_dev_local/pkg/utils"
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

// DeployRedis deploys the Bitnami Redis Helm chart for both Istio rate limiting and application usage
func DeployRedis(ctx *pulumi.Context, provider *kubernetes.Provider) (pulumi.Resource, error) {
	// Use config utils implementation
	cfg := utils.NewConfig(ctx)

	// Get Redis password from config
	redisPassword := cfg.GetString("redis_password", "redis-password")

	// Create Redis chart resource using the resources package
	return resources.DeployHelmChart(ctx, provider, resources.HelmChartConfig{
		Name:            "redis",
		ChartName:       "redis",
		Version:         cfg.GetString("redis_version", "18.19.1"),
		RepositoryURL:   "https://charts.bitnami.com/bitnami",
		Namespace:       "redis",
		CreateNamespace: true,
		ValuesFile:      "redis", // Will load values/redis.yaml
		// Only override values that come from configuration
		Values: map[string]interface{}{
			"auth": map[string]interface{}{
				"password": redisPassword,
			},
		},
		Wait:    true,
		Timeout: 1200,
	}) // End of DeployRedis
}
