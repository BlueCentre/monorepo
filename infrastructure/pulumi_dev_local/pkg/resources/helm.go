package resources

import (
	"fmt"

	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes"
	corev1 "github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/core/v1"
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/helm/v3"
	metav1 "github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/meta/v1"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"

	"github.com/james/monorepo/pulumi_dev_local/pkg/utils"
)

// HelmChartConfig defines the configuration for a Helm chart deployment
type HelmChartConfig struct {
	Name            string
	Namespace       string
	ChartName       string
	RepositoryURL   string
	Version         string
	Values          map[string]interface{}
	ValuesFile      string // Name of the values file to load (without .yaml extension)
	CreateNamespace bool
	SkipCRDs        bool // Whether to skip CRD installation
	Timeout         int  // in seconds
	Wait            bool
	// New fields for cleanup
	CleanupCRDs       bool     // Enables CRD cleanup for charts like cert-manager
	CRDsToCleanup     []string // List of CRD patterns to clean up (e.g., "*.cert-manager.io")
	WebhooksToCleanup []string // List of webhook names to clean up
	// New field for replace functionality
	Replace bool // Whether to replace the release if it already exists
}

// DeployHelmChart creates a Helm chart release with given configuration
func DeployHelmChart(ctx *pulumi.Context, provider *kubernetes.Provider, config HelmChartConfig, opts ...pulumi.ResourceOption) (*helm.Release, error) {
	// Create the namespace if needed
	if config.CreateNamespace {
		_, err := CreateK8sNamespace(ctx, provider, K8sNamespaceConfig{
			Name: config.Namespace,
		})
		if err != nil {
			return nil, err
		}
	}

	// Load values from external YAML file if specified
	fileValues := map[string]interface{}{}
	var err error
	if config.ValuesFile != "" {
		fileValues, err = utils.LoadHelmValues(config.ValuesFile)
		if err != nil {
			return nil, fmt.Errorf("error loading values file for %s: %w", config.Name, err)
		}
	}

	// Merge file values with provided values (provided values take precedence)
	mergedValues := utils.MergeValues(fileValues, config.Values)

	// If CleanupCRDs is true, create and run a cleanup script before installing the chart
	if config.CleanupCRDs && len(config.CRDsToCleanup) > 0 {
		cmName := fmt.Sprintf("%s-crd-cleanup", config.Name)

		// Create a cleanup script
		cleanupScript := "#!/bin/sh\n\n"
		cleanupScript += "set -e\n\n"

		for _, crd := range config.CRDsToCleanup {
			cleanupScript += fmt.Sprintf("kubectl get crd %s > /dev/null 2>&1 && kubectl delete crd %s || echo \"CRD %s not found, skipping\"\n", crd, crd, crd)
		}

		// Create a ConfigMap to store the cleanup script
		_, err := corev1.NewConfigMap(ctx, cmName, &corev1.ConfigMapArgs{
			Metadata: &metav1.ObjectMetaArgs{
				Name:      pulumi.String(cmName),
				Namespace: pulumi.String(config.Namespace),
			},
			Data: pulumi.StringMap{
				"cleanup.sh": pulumi.String(cleanupScript),
			},
		}, pulumi.Provider(provider))

		if err != nil {
			return nil, err
		}

		// Run the cleanup script
		cleanupJobName := fmt.Sprintf("%s-cleanup-job", config.Name)
		cleanupPod, err := corev1.NewPod(ctx, cleanupJobName, &corev1.PodArgs{
			Metadata: &metav1.ObjectMetaArgs{
				Name:      pulumi.String(cleanupJobName),
				Namespace: pulumi.String(config.Namespace),
			},
			Spec: &corev1.PodSpecArgs{
				RestartPolicy: pulumi.String("Never"),
				Containers: corev1.ContainerArray{
					&corev1.ContainerArgs{
						Name:  pulumi.String("cleanup"),
						Image: pulumi.String("bitnami/kubectl:latest"),
						Command: pulumi.StringArray{
							pulumi.String("sh"),
							pulumi.String("/scripts/cleanup.sh"),
						},
						VolumeMounts: corev1.VolumeMountArray{
							&corev1.VolumeMountArgs{
								Name:      pulumi.String("cleanup-script"),
								MountPath: pulumi.String("/scripts"),
							},
						},
					},
				},
				Volumes: corev1.VolumeArray{
					&corev1.VolumeArgs{
						Name: pulumi.String("cleanup-script"),
						ConfigMap: &corev1.ConfigMapVolumeSourceArgs{
							Name:        pulumi.String(cmName),
							DefaultMode: pulumi.Int(0755),
						},
					},
				},
			},
		}, pulumi.Provider(provider))

		if err != nil {
			return nil, err
		}

		// Add the cleanup job as a dependency for the chart
		opts = append(opts, pulumi.DependsOn([]pulumi.Resource{cleanupPod}))
	}

	// Prepare the values map
	valueMap := pulumi.Map{}
	for k, v := range mergedValues {
		valueMap[k] = convertToPulumiValue(v)
	}

	// Build release arguments
	releaseArgs := &helm.ReleaseArgs{
		Chart: pulumi.String(config.ChartName),
		RepositoryOpts: &helm.RepositoryOptsArgs{
			Repo: pulumi.String(config.RepositoryURL),
		},
		Version:         pulumi.String(config.Version),
		Namespace:       pulumi.String(config.Namespace),
		Values:          valueMap,
		Name:            pulumi.String(config.Name),
		CreateNamespace: pulumi.Bool(config.CreateNamespace),
		SkipCrds:        pulumi.Bool(config.SkipCRDs),
	}

	// Set optional parameters
	if config.Wait {
		releaseArgs.WaitForJobs = pulumi.Bool(config.Wait)
	}

	if config.Timeout > 0 {
		releaseArgs.Timeout = pulumi.Int(config.Timeout)
	}

	// Add replace flag if needed
	if config.Replace {
		releaseArgs.Replace = pulumi.Bool(config.Replace)
	}

	// Add provider to options
	opts = append(opts, pulumi.Provider(provider))

	// Create the release
	return helm.NewRelease(ctx, config.Name, releaseArgs, opts...)
}

// Helper function to generate a cleanup script
func generateCleanupScript(crds []string, webhooks []string) string {
	script := "#!/bin/bash\n\n"

	// Clean up CRDs
	if len(crds) > 0 {
		script += "# Clean up CRDs\n"
		for _, crd := range crds {
			script += fmt.Sprintf("kubectl get crd | grep %s | awk '{print $1}' | xargs -r kubectl delete crd\n", crd)
		}
	}

	// Clean up webhooks
	if len(webhooks) > 0 {
		script += "\n# Clean up webhooks\n"
		for _, webhook := range webhooks {
			script += fmt.Sprintf("kubectl delete validatingwebhookconfiguration %s 2>/dev/null || true\n", webhook)
			script += fmt.Sprintf("kubectl delete mutatingwebhookconfiguration %s 2>/dev/null || true\n", webhook)
		}
	}

	return script
}

// RunCommandResourceConfig defines configuration for a custom command resource
type RunCommandResourceConfig struct {
	Name        string
	Namespace   string
	Labels      map[string]string
	Annotations map[string]string
	Data        map[string]string
}

// CreateRunCommandResource creates a ConfigMap to help with cleanup
func CreateRunCommandResource(ctx *pulumi.Context, provider *kubernetes.Provider, config RunCommandResourceConfig, opts ...pulumi.ResourceOption) (*corev1.ConfigMap, error) {
	// Add provider to options
	opts = append(opts, pulumi.Provider(provider))

	// Convert maps to Pulumi maps
	labelMap := pulumi.StringMap{}
	for k, v := range config.Labels {
		labelMap[k] = pulumi.String(v)
	}

	annotationMap := pulumi.StringMap{}
	for k, v := range config.Annotations {
		annotationMap[k] = pulumi.String(v)
	}

	dataMap := pulumi.StringMap{}
	for k, v := range config.Data {
		dataMap[k] = pulumi.String(v)
	}

	// Create a ConfigMap that contains information about what to clean up
	return corev1.NewConfigMap(ctx, config.Name, &corev1.ConfigMapArgs{
		Metadata: &metav1.ObjectMetaArgs{
			Name:        pulumi.String(config.Name),
			Namespace:   pulumi.String(config.Namespace),
			Labels:      labelMap,
			Annotations: annotationMap,
		},
		Data: dataMap,
	}, opts...)
}

// Helper function to convert Go values to Pulumi values
func convertToPulumiValue(v interface{}) pulumi.Input {
	switch val := v.(type) {
	case string:
		return pulumi.String(val)
	case int:
		return pulumi.Int(val)
	case bool:
		return pulumi.Bool(val)
	case float64:
		return pulumi.Float64(val)
	case map[string]interface{}:
		m := pulumi.Map{}
		for k, v2 := range val {
			m[k] = convertToPulumiValue(v2)
		}
		return m
	case []interface{}:
		var arr []pulumi.Input
		for _, v2 := range val {
			arr = append(arr, convertToPulumiValue(v2))
		}
		return pulumi.Array(arr)
	default:
		// Default to string representation
		return pulumi.String(fmt.Sprintf("%v", v))
	}
}
