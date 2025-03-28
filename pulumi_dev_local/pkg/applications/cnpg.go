package applications

import (
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"

	"github.com/james/monorepo/pulumi_dev_local/pkg/resources"
	"github.com/james/monorepo/pulumi_dev_local/pkg/utils"
)

// CNPGCRDs is a list of all CloudNativePG CRDs
var CNPGCRDs = []string{
	"backups.postgresql.cnpg.io",
	"clusters.postgresql.cnpg.io",
	"poolers.postgresql.cnpg.io",
	"scheduledbackups.postgresql.cnpg.io",
}

// DeployCloudNativePG installs CloudNativePG operator
func DeployCloudNativePG(ctx *pulumi.Context, provider *kubernetes.Provider) (pulumi.Resource, error) {
	// Get configuration
	conf := utils.NewConfig(ctx)
	enabled := conf.GetBool("cnpg_enabled", true)
	version := conf.GetString("cnpg_version", "0.23.2")

	if !enabled {
		ctx.Log.Info("CloudNativePG is disabled, skipping deployment", nil)
		return nil, nil
	}

	// Create namespace
	namespace := conf.GetString("cnpg:namespace", "cnpg-system")
	ns, err := resources.CreateK8sNamespace(ctx, provider, resources.K8sNamespaceConfig{
		Name: namespace,
	})

	if err != nil {
		return nil, err
	}

	// Deploy CloudNativePG using the common function
	cnpg, err := resources.DeployHelmChart(ctx, provider, resources.HelmChartConfig{
		Name:            "cnpg",
		Namespace:       namespace,
		ChartName:       "cloudnative-pg", // NOTICE: Could be cluster chart
		RepositoryURL:   "https://cloudnative-pg.github.io/charts",
		Version:         version,
		CreateNamespace: false, // We created it already above
		ValuesFile:      "cnpg",
		Values:          map[string]interface{}{
			// NOTE: For cluster chart
			// "mode": "standalone",
			// "cluster": map[string]interface{}{
			// 	"instances": 1,
			// },
			// "backups": map[string]interface{}{
			// 	"enabled": false,
			// },
		},
		Wait:          true,
		Timeout:       600,
		CleanupCRDs:   false,
		CRDsToCleanup: CNPGCRDs,
	}, pulumi.DependsOn([]pulumi.Resource{ns}))

	if err != nil {
		return nil, err
	}

	// Export CloudNativePG information
	ctx.Export("cnpgNamespace", pulumi.String(namespace))

	return cnpg, nil
}
