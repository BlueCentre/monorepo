package resources

import (
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes"
	corev1 "github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/core/v1"
	metav1 "github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/meta/v1"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

// NamespaceConfig defines configuration for a Kubernetes namespace
type NamespaceConfig struct {
	Name   string
	Labels map[string]string
}

// CreateNamespace creates a Kubernetes namespace if it doesn't exist
func CreateNamespace(ctx *pulumi.Context, provider *kubernetes.Provider, config NamespaceConfig) (*corev1.Namespace, error) {
	// Convert the labels map to pulumi.StringMap
	labelMap := pulumi.StringMap{}
	for k, v := range config.Labels {
		labelMap[k] = pulumi.String(v)
	}

	// Create the namespace
	ns, err := corev1.NewNamespace(ctx, config.Name, &corev1.NamespaceArgs{
		Metadata: &metav1.ObjectMetaArgs{
			Name:   pulumi.String(config.Name),
			Labels: labelMap,
		},
	}, pulumi.Provider(provider))

	return ns, err
}

// ConfigMapConfig defines configuration for a Kubernetes ConfigMap
type ConfigMapConfig struct {
	Name      string
	Namespace string
	Data      map[string]string
}

// CreateConfigMap creates a Kubernetes ConfigMap
func CreateConfigMap(ctx *pulumi.Context, provider *kubernetes.Provider, config ConfigMapConfig) (*corev1.ConfigMap, error) {
	// Convert the data map to pulumi.StringMap
	dataMap := pulumi.StringMap{}
	for k, v := range config.Data {
		dataMap[k] = pulumi.String(v)
	}

	// Create the ConfigMap
	cm, err := corev1.NewConfigMap(ctx, config.Name, &corev1.ConfigMapArgs{
		Metadata: &metav1.ObjectMetaArgs{
			Name:      pulumi.String(config.Name),
			Namespace: pulumi.String(config.Namespace),
		},
		Data: dataMap,
	}, pulumi.Provider(provider))

	return cm, err
}
