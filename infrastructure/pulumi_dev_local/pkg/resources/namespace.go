package resources

import (
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes"
	corev1 "github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/core/v1"
	metav1 "github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/meta/v1"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

// K8sNamespaceConfig defines the configuration for a Kubernetes namespace
type K8sNamespaceConfig struct {
	Name   string
	Labels map[string]string
}

// CreateK8sNamespace creates a Kubernetes namespace with the given configuration
func CreateK8sNamespace(ctx *pulumi.Context, provider *kubernetes.Provider, config K8sNamespaceConfig) (*corev1.Namespace, error) {
	// Prepare labels
	labels := pulumi.StringMap{}
	for k, v := range config.Labels {
		labels[k] = pulumi.String(v)
	}

	// Create the namespace
	return corev1.NewNamespace(ctx, config.Name, &corev1.NamespaceArgs{
		Metadata: &metav1.ObjectMetaArgs{
			Name:   pulumi.String(config.Name),
			Labels: labels,
		},
	}, pulumi.Provider(provider))
}
