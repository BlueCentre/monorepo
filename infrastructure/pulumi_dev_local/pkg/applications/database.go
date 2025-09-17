package applications

import (
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"

	"github.com/james/monorepo/pulumi_dev_local/pkg/resources"
	"github.com/james/monorepo/pulumi_dev_local/pkg/utils"
)

// DeployDatabase sets up a PostgreSQL database
func DeployDatabase(ctx *pulumi.Context, provider *kubernetes.Provider) error {
	// Get configuration
	conf := utils.NewConfig(ctx)
	enabled := conf.GetBool("database_enabled", true)

	if !enabled {
		ctx.Log.Info("Database is disabled, skipping deployment", nil)
		return nil
	}

	// Create namespace
	namespace := conf.GetString("database:namespace", "database")
	ns, err := resources.CreateK8sNamespace(ctx, provider, resources.K8sNamespaceConfig{
		Name: namespace,
	})

	if err != nil {
		return err
	}

	// Deploy PostgreSQL
	_, err = resources.DeployHelmChart(ctx, provider, resources.HelmChartConfig{
		Name:            "postgresql",
		Namespace:       namespace,
		ChartName:       "postgresql",
		RepositoryURL:   "https://charts.bitnami.com/bitnami",
		Version:         "12.5.7",
		CreateNamespace: false,
		Values: map[string]interface{}{
			"auth": map[string]interface{}{
				"username":         "postgres",
				"password":         "postgres",
				"database":         "postgres",
				"postgresPassword": "postgres",
			},
			"primary": map[string]interface{}{
				"persistence": map[string]interface{}{
					"enabled": true,
					"size":    "1Gi",
				},
				"resources": map[string]interface{}{
					"requests": map[string]interface{}{
						"cpu":    "100m",
						"memory": "256Mi",
					},
				},
			},
		},
		Wait:    true,
		Timeout: 300,
	}, pulumi.DependsOn([]pulumi.Resource{ns}))

	// Export database connection information
	ctx.Export("databaseNamespace", pulumi.String(namespace))
	ctx.Export("databaseHost", pulumi.String("postgresql."+namespace+".svc.cluster.local"))
	ctx.Export("databasePort", pulumi.Int(5432))
	ctx.Export("databaseUsername", pulumi.String("postgres"))
	ctx.Export("databasePassword", pulumi.String("postgres"))
	ctx.Export("databaseName", pulumi.String("postgres"))

	return err
}
