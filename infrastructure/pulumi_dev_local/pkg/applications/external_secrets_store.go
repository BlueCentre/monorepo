package applications

import (
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"

	"github.com/james/monorepo/pulumi_dev_local/pkg/resources"
)

// DeployExternalSecretsStore sets up the fake secret store for external-secrets
func DeployExternalSecretsStore(ctx *pulumi.Context, provider *kubernetes.Provider) error {
	// Create the ClusterSecretStore for fake secrets
	_, err := resources.CreateK8sManifest(ctx, provider, resources.K8sManifestConfig{
		Name: "fake-secret-store",
		YAML: `
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: external-secret-cluster-fake-secrets
  namespace: external-secrets
spec:
  provider:
    fake:
      data:
      - key: "CLOUDFLARE_API_TOKEN"
        value: "fake-api-token"
        version: "v1"
`,
	})

	return err
}
