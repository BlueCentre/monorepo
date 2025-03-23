package resources

import (
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes"
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/yaml"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

// K8sManifestConfig defines the configuration for a Kubernetes manifest
type K8sManifestConfig struct {
	Name string
	YAML string
}

// CreateK8sManifest creates a Kubernetes manifest from YAML
func CreateK8sManifest(ctx *pulumi.Context, provider *kubernetes.Provider, config K8sManifestConfig, opts ...pulumi.ResourceOption) (*yaml.ConfigGroup, error) {
	// Add provider to options
	opts = append(opts, pulumi.Provider(provider))

	// Create the manifest
	return yaml.NewConfigGroup(ctx, config.Name, &yaml.ConfigGroupArgs{
		YAML: []string{config.YAML},
	}, opts...)
}
