package applications

import (
	"fmt"

	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes"
	kubernetescorev1 "github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/core/v1"
	metav1 "github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/meta/v1"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"

	"github.com/james/monorepo/pulumi_dev_local/pkg/resources"
	"github.com/james/monorepo/pulumi_dev_local/pkg/utils"
)

// CNPGCRDs is a list of all CloudNativePG CRDs - Kept for reference if needed later
var CNPGCRDs = []string{
	"backups.postgresql.cnpg.io",
	"clusterimagecatalog.postgresql.cnpg.io",
	"cluster.postgresql.cnpg.io",
	"database.postgresql.cnpg.io",
	"imagecatalog.postgresql.cnpg.io",
	"pooler.postgresql.cnpg.io",
	"publication.postgresql.cnpg.io",
	"scheduledbackup.postgresql.cnpg.io",
	"subscription.postgresql.cnpg.io",
}

// DeployCloudNativePGOperator installs the CloudNativePG operator Helm chart.
// It returns the Helm release resource and an error if any occurred.
func DeployCloudNativePGOperator(ctx *pulumi.Context, provider *kubernetes.Provider) (pulumi.Resource, error) {
	// Get configuration for the operator
	conf := utils.NewConfig(ctx)
	operatorVersion := conf.GetString("cnpg_operator_version", "0.23.2")
	operatorNamespace := conf.GetString("cnpg_operator_namespace", "cnpg-system")

	// Deploy CloudNativePG Operator using the common function
	operatorRelease, err := resources.DeployHelmChart(ctx, provider, resources.HelmChartConfig{
		Name:            "cnpg-operator",                           // Changed name to be specific
		Namespace:       operatorNamespace,                         // Use operator specific namespace
		ChartName:       "cloudnative-pg",                          // This is the correct chart for the operator
		RepositoryURL:   "https://cloudnative-pg.github.io/charts", // Repository URL remains the same
		Version:         operatorVersion,                           // Use operator specific version
		CreateNamespace: true,                                      // Operator needs its namespace
		ValuesFile:      "cnpg-operator",                           // Use the renamed values file
		Wait:            true,                                      // Wait for the operator to be ready
		CleanupCRDs:     true,                                      // Cleanup the CRDs
		CRDsToCleanup:   CNPGCRDs,
		Timeout:         600, // Standard timeout
	})

	if err != nil {
		ctx.Log.Error("Failed to deploy CloudNativePG Operator Helm chart.", &pulumi.LogArgs{Resource: nil})
		return nil, err
	}

	ctx.Log.Info("CloudNativePG Operator Helm chart deployed successfully.", nil)

	// Export CloudNativePG Operator information
	ctx.Export("cnpgOperatorNamespace", pulumi.String(operatorNamespace))

	return operatorRelease, nil
}

// DeployCnpgCluster creates the initial application credentials secret and deploys the CNPG Cluster Helm chart.
// It depends on the successful deployment of the CNPG operator.
// Returns the Helm release resource and an error if any occurred.
func DeployCnpgCluster(ctx *pulumi.Context, provider *kubernetes.Provider, operatorRelease pulumi.Resource) (pulumi.Resource, error) {
	conf := utils.NewConfig(ctx)
	// --- Configuration --- //
	clusterNamespace := conf.GetString("cnpg_cluster_namespace", "cnpg-cluster")
	clusterVersion := conf.GetString("cnpg_cluster_version", "0.2.1")
	appDbName := conf.GetString("cnpg_app_db_name", "app")
	appDbUser := conf.GetString("cnpg_app_db_user", "app_user")
	appDbPasswordOutput := conf.RequireSecret(ctx, "cnpg_app_db_password")

	// Ensure we have a dependency on the operator being ready
	var dependsOnOperator pulumi.ResourceOption
	if operatorRelease != nil {
		dependsOnOperator = pulumi.DependsOn([]pulumi.Resource{operatorRelease})
	} else {
		// If operator deployment was skipped, we cannot proceed with cluster deployment.
		ctx.Log.Error("Cannot deploy CNPG Cluster: Operator resource is nil (likely disabled or failed).", nil)
		return nil, fmt.Errorf("CNPG operator deployment is required but was not successful")
	}

	// --- Secret Creation --- //
	initialSecretName := "cnpg-initial-app-credentials"
	appCredentialsSecret, err := kubernetescorev1.NewSecret(ctx, initialSecretName, &kubernetescorev1.SecretArgs{
		Metadata: &metav1.ObjectMetaArgs{
			Name:      pulumi.String(initialSecretName),
			Namespace: pulumi.String(clusterNamespace), // Create secret in the cluster namespace
		},
		Type: pulumi.String("kubernetes.io/basic-auth"),
		StringData: pulumi.StringMap{
			"username": pulumi.String(appDbUser),
			"password": appDbPasswordOutput, // Use the StringOutput directly
		},
	}, pulumi.Provider(provider), dependsOnOperator) // Depend on operator
	if err != nil {
		return nil, fmt.Errorf("failed to create CNPG initial app credentials secret: %w", err)
	}

	// --- Helm Chart Deployment --- //
	// The cluster Helm chart requires the operator and the credentials secret to exist first.
	clusterDependsOn := []pulumi.Resource{appCredentialsSecret, operatorRelease}

	clusterRelease, err := resources.DeployHelmChart(ctx, provider, resources.HelmChartConfig{
		Name:            "cnpg-cluster",                            // Specific name for the cluster release
		Namespace:       clusterNamespace,                          // Deploy into the cluster namespace
		ChartName:       "cluster",                                 // Use the 'cluster' chart from the CNPG repo
		RepositoryURL:   "https://cloudnative-pg.github.io/charts", // Same repo URL as operator
		Version:         clusterVersion,                            // Use cluster specific version
		CreateNamespace: true,                                      // Ensure the cluster namespace exists
		ValuesFile:      "cnpg-cluster",                            // Use the new values file
		Values: map[string]interface{}{ // Dynamic values mirroring Terraform template
			"cluster": map[string]interface{}{
				"initdb": map[string]interface{}{
					"database": appDbName,
					"owner":    appDbUser, // Owner derived from secret
					"secret": map[string]interface{}{
						"name": initialSecretName, // Reference the created secret
					},
				},
			},
		},
		Wait:    false, // Changed from true based on Terraform (wait = false)
		Timeout: 600,   // Standard timeout
	}, pulumi.DependsOn(clusterDependsOn))

	if err != nil {
		ctx.Log.Error(fmt.Sprintf("Failed to deploy CNPG Cluster Helm chart %s", "cnpg-cluster"), &pulumi.LogArgs{Resource: clusterRelease})
		return nil, err
	}

	ctx.Log.Info(fmt.Sprintf("CNPG Cluster Helm chart %s deployed successfully", "cnpg-cluster"), nil)

	// Export Cluster Information
	ctx.Export("cnpgClusterNamespace", pulumi.String(clusterNamespace))
	ctx.Export("cnpgInitialAppSecretName", appCredentialsSecret.Metadata.Name())

	return clusterRelease, nil
}
