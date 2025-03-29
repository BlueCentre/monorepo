package applications

import (
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"

	"github.com/james/monorepo/pulumi_dev_local/pkg/resources"
	"github.com/james/monorepo/pulumi_dev_local/pkg/utils"
)

// CertManagerCRDs is a list of all cert-manager CRDs
var CertManagerCRDs = []string{
	"certificaterequests.cert-manager.io",
	"certificates.cert-manager.io",
	"challenges.acme.cert-manager.io",
	"clusterissuers.cert-manager.io",
	"issuers.cert-manager.io",
	"orders.acme.cert-manager.io",
}

// DeployCertManager installs cert-manager
func DeployCertManager(ctx *pulumi.Context, provider *kubernetes.Provider) (pulumi.Resource, error) {
	// Get configuration
	conf := utils.NewConfig(ctx)
	version := conf.GetString("cert_manager_version", "v1.17.0")
	namespace := conf.GetString("cert_manager_namespace", "cert-manager")

	// Deploy cert-manager with CRD management - leveraging the common function
	certManager, err := resources.DeployHelmChart(ctx, provider, resources.HelmChartConfig{
		Name:            "cert-manager",
		Namespace:       namespace,
		ChartName:       "cert-manager",
		RepositoryURL:   "https://charts.jetstack.io",
		Version:         version,
		CreateNamespace: true,
		ValuesFile:      "cert-manager",
		Values: map[string]interface{}{
			// "startupapicheck": map[string]interface{}{
			// 	"enabled": false,
			// },
			"prometheus": map[string]interface{}{
				"enabled": false,
			},
		},
		Wait:          true, // Set to true to ensure it's fully deployed before OpenTelemetry
		Timeout:       600,
		CleanupCRDs:   false,
		CRDsToCleanup: CertManagerCRDs,
	})

	if err != nil {
		return nil, err
	}

	// Create a self-signed cluster issuer - Re-commented as it didn't solve the issue
	// and differs from working Terraform setup.
	// _, err = resources.CreateK8sManifest(ctx, provider, resources.K8sManifestConfig{
	// 	Name: "cert-manager-selfsigned-cluster-issuer", // Resource name in Pulumi state
	// 	YAML: `apiVersion: cert-manager.io/v1
	// kind: ClusterIssuer
	// metadata:
	//   # Ensure this name matches the one used in OpenTelemetry's issuerRef
	//   name: selfsigned-cluster-issuer
	// spec:
	//   selfSigned: {}`,
	// }, pulumi.DependsOn([]pulumi.Resource{certManager})) // Depend on the Helm release being ready

	// if err != nil {
	// 	// Log the error but potentially continue, depending on desired behavior.
	// 	// Returning the error might be safer.
	// 	ctx.Log.Error("Failed to create self-signed ClusterIssuer", &pulumi.LogArgs{Resource: certManager})
	// 	return nil, fmt.Errorf("failed to create self-signed ClusterIssuer: %w", err)
	// }

	// ctx.Log.Info("Self-signed ClusterIssuer created successfully.", nil)

	// Export cert-manager information
	ctx.Export("certManagerNamespace", pulumi.String(namespace))
	// ctx.Export("selfSignedClusterIssuerName", pulumi.String("selfsigned-cluster-issuer")) // Export the actual name

	// Return the Helm release resource and nil error if issuer creation is commented out
	return certManager, nil
}
