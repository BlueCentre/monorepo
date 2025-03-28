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
	enabled := conf.GetBool("cert_manager_enabled", true)
	version := conf.GetString("cert_manager_version", "v1.17.0")

	if !enabled {
		ctx.Log.Info("Cert-manager is disabled, skipping deployment", nil)
		return nil, nil
	}

	// Create namespace
	namespace := conf.GetString("cert_manager:namespace", "cert-manager")
	ns, err := resources.CreateK8sNamespace(ctx, provider, resources.K8sNamespaceConfig{
		Name: namespace,
	})

	if err != nil {
		return nil, err
	}

	// Deploy cert-manager with CRD management - leveraging the common function
	certManager, err := resources.DeployHelmChart(ctx, provider, resources.HelmChartConfig{
		Name:            "cert-manager",
		Namespace:       namespace,
		ChartName:       "cert-manager",
		RepositoryURL:   "https://charts.jetstack.io",
		Version:         version,
		CreateNamespace: false,
		ValuesFile:      "cert-manager",
		Values: map[string]interface{}{
			"startupapicheck": map[string]interface{}{
				"enabled": false,
			},
			"prometheus": map[string]interface{}{
				"enabled": false,
			},
		},
		Wait:          true, // Set to true to ensure it's fully deployed before OpenTelemetry
		Timeout:       600,
		CleanupCRDs:   false,
		CRDsToCleanup: CertManagerCRDs,
	}, pulumi.DependsOn([]pulumi.Resource{ns}))

	if err != nil {
		return nil, err
	}

	// Create a self-signed cluster issuer
	// 	_, err = resources.CreateK8sManifest(ctx, provider, resources.K8sManifestConfig{
	// 		Name: "cert-manager-self-signed-cluster-issuer",
	// 		YAML: `apiVersion: cert-manager.io/v1
	// kind: ClusterIssuer
	// metadata:
	//   name: selfsigned-issuer
	// spec:
	//   selfSigned: {}`,
	// 	}, pulumi.DependsOn([]pulumi.Resource{certManager}))

	// Export cert-manager information
	ctx.Export("certManagerNamespace", pulumi.String(namespace))
	// ctx.Export("selfSignedIssuer", pulumi.String("selfsigned-issuer"))

	return certManager, err
}
