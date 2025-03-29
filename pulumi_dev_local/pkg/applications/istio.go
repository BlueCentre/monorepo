package applications

import (
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"

	"github.com/james/monorepo/pulumi_dev_local/pkg/resources"
	"github.com/james/monorepo/pulumi_dev_local/pkg/utils"
)

// DeployIstio deploys Istio service mesh components
func DeployIstio(ctx *pulumi.Context, provider *kubernetes.Provider) error {
	// Get configuration
	conf := utils.NewConfig(ctx)
	version := conf.GetString("istio_version", "1.23.3")

	// Set the namespace for Istio
	namespace := "istio-system"

	// List of Istio CRDs to clean up
	istioCRDs := []string{
		"authorizationpolicies.security.istio.io",
		"destinationrules.networking.istio.io",
		"envoyfilters.networking.istio.io",
		"gateways.networking.istio.io",
		"istiooperators.install.istio.io",
		"peerauthentications.security.istio.io",
		"requestauthentications.security.istio.io",
		"serviceentries.networking.istio.io",
		"sidecars.networking.istio.io",
		"virtualservices.networking.istio.io",
		"workloadentries.networking.istio.io",
		"workloadgroups.networking.istio.io",
	}

	// Deploy Istio base with CRD management
	istioBase, err := resources.DeployHelmChart(ctx, provider, resources.HelmChartConfig{
		Name:            "istio-base",
		Namespace:       namespace,
		ChartName:       "base",
		RepositoryURL:   "https://istio-release.storage.googleapis.com/charts",
		Version:         version,
		CreateNamespace: true,
		ValuesFile:      "istio-base",
		Wait:            true,
		Timeout:         600,
		CleanupCRDs:     false,
		CRDsToCleanup:   istioCRDs,
	})

	if err != nil {
		return err
	}

	// Deploy Istio CNI
	istioCNI, err := resources.DeployHelmChart(ctx, provider, resources.HelmChartConfig{
		Name:            "istio-cni",
		Namespace:       namespace,
		ChartName:       "cni",
		RepositoryURL:   "https://istio-release.storage.googleapis.com/charts",
		Version:         version,
		CreateNamespace: false,
		Values: map[string]interface{}{
			"cniBinDir": "/home/kubernetes/bin",
		},
		Wait:        true,
		Timeout:     600,
		CleanupCRDs: false,
	}, pulumi.DependsOn([]pulumi.Resource{istioBase}))

	if err != nil {
		return err
	}

	// Deploy Istio istiod control plane - depend directly on the cleanup pod
	istiod, err := resources.DeployHelmChart(ctx, provider, resources.HelmChartConfig{
		Name:            "istiod",
		Namespace:       namespace,
		ChartName:       "istiod",
		RepositoryURL:   "https://istio-release.storage.googleapis.com/charts",
		Version:         version,
		CreateNamespace: false,
		Values:          map[string]interface{}{},
		Wait:            true,
		Timeout:         600,
	}, pulumi.DependsOn([]pulumi.Resource{istioBase, istioCNI}))
	// }, pulumi.DependsOn([]pulumi.Resource{istioBase, istioCNI, cleanupPod}))

	if err != nil {
		return err
	}

	// Deploy Istio ingress gateway
	istioIngressGateway, err := resources.DeployHelmChart(ctx, provider, resources.HelmChartConfig{
		Name:            "istio-ingressgateway",
		Namespace:       namespace,
		ChartName:       "gateway",
		RepositoryURL:   "https://istio-release.storage.googleapis.com/charts",
		Version:         version,
		CreateNamespace: false,
		Values:          map[string]interface{}{},
		Wait:            true,
		Timeout:         600,
	}, pulumi.DependsOn([]pulumi.Resource{istioBase, istiod}))

	if err != nil {
		return err
	}

	// Deploy rate limiting EnvoyFilters if Redis is enabled
	redisEnabled := conf.GetBool("redis_enabled", false)
	if redisEnabled {
		// Rate Limit Service EnvoyFilter
		_, err = resources.CreateK8sManifest(ctx, provider, resources.K8sManifestConfig{
			Name: "istio-rate-limit-service",
			YAML: `apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: rate-limit-service
  namespace: istio-system
spec:
  workloadSelector:
    labels:
      istio: ingressgateway
  configPatches:
  - applyTo: CLUSTER
    match:
      context: GATEWAY
    patch:
      operation: ADD
      value:
        name: rate_limit_service
        type: STRICT_DNS
        connect_timeout: 10s
        lb_policy: ROUND_ROBIN
        http2_protocol_options: {}
        load_assignment:
          cluster_name: rate_limit_service
          endpoints:
          - lb_endpoints:
            - endpoint:
                address:
                  socket_address:
                    address: redis-master.redis.svc.cluster.local
                    port_value: 6379`,
		}, pulumi.DependsOn([]pulumi.Resource{istioIngressGateway}))
		if err != nil {
			return err
		}

		// Filter Rate Limit EnvoyFilter
		_, err = resources.CreateK8sManifest(ctx, provider, resources.K8sManifestConfig{
			Name: "filter-ratelimit",
			YAML: `apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: filter-ratelimit
  namespace: istio-system
spec:
  workloadSelector:
    labels:
      istio: ingressgateway
  configPatches:
  - applyTo: HTTP_FILTER
    match:
      context: GATEWAY
      listener:
        filterChain:
          filter:
            name: envoy.filters.network.http_connection_manager
    patch:
      operation: INSERT_BEFORE
      value:
        name: envoy.filters.http.ratelimit
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.http.ratelimit.v3.RateLimit
          domain: redis-rate-limit
          failure_mode_deny: true
          rate_limit_service:
            grpc_service:
              envoy_grpc:
                cluster_name: rate_limit_service
              timeout: 10s
            transport_api_version: V3`,
		}, pulumi.DependsOn([]pulumi.Resource{istioIngressGateway}))
		if err != nil {
			return err
		}

		// RateLimit Config EnvoyFilter
		_, err = resources.CreateK8sManifest(ctx, provider, resources.K8sManifestConfig{
			Name: "ratelimit-config",
			YAML: `apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: ratelimit-config
  namespace: istio-system
spec:
  workloadSelector:
    labels:
      istio: ingressgateway
  configPatches:
  - applyTo: VIRTUAL_HOST
    match:
      context: GATEWAY
      routeConfiguration:
        vhost:
          name: "*:80"
    patch:
      operation: MERGE
      value:
        rate_limits:
        - actions:
          - request_headers:
              header_name: ":path"
              descriptor_key: path`,
		}, pulumi.DependsOn([]pulumi.Resource{istioIngressGateway}))
		if err != nil {
			return err
		}
	}

	// 	// Create a cleanup script for ClusterRoleBinding that's causing conflicts
	// 	cleanupCmName := "istiod-clusterrolebinding-cleanup"
	// 	cleanupScript := `#!/bin/sh

	// set -e

	// # Set the namespace for Istio
	// NAMESPACE="istio-system"

	// echo "Starting Istio resources cleanup..."

	// # Function to clean up resource by label pattern
	// clean_resources_by_label() {
	//   resource_type=$1
	//   label_selector=$2

	//   echo "Looking for $resource_type with label selector: $label_selector"

	//   # Get resources matching the selector and delete them
	//   resources=$(kubectl get $resource_type -l $label_selector -o name 2>/dev/null || echo "")

	//   if [ -n "$resources" ]; then
	//     echo "Found resources to clean up: $resources"
	//     kubectl delete $resource_type -l $label_selector
	//     echo "$resource_type cleanup complete"
	//   else
	//     echo "No $resource_type found with label $label_selector"
	//   fi
	// }

	// # Function to clean up resources by name pattern
	// clean_resources_by_pattern() {
	//   resource_type=$1
	//   pattern=$2
	//   namespace=$3

	//   ns_arg=""
	//   if [ -n "$namespace" ]; then
	//     ns_arg="-n $namespace"
	//   fi

	//   echo "Looking for $resource_type with name pattern: $pattern"

	//   # Get resources matching pattern and delete them
	//   resources=$(kubectl get $resource_type $ns_arg 2>/dev/null | grep "$pattern" | awk '{print $1}' || echo "")

	//   if [ -n "$resources" ]; then
	//     echo "Found resources to clean up:"
	//     echo "$resources" | while read resource; do
	//       echo "Deleting $resource_type/$resource $ns_arg"
	//       kubectl delete $resource_type $resource $ns_arg
	//     done
	//     echo "$resource_type pattern cleanup complete"
	//   else
	//     echo "No $resource_type found matching pattern $pattern"
	//   fi
	// }

	// # Clean up ClusterRoleBindings
	// echo "Cleaning up ClusterRoleBindings related to Istio..."
	// clean_resources_by_pattern "clusterrolebinding" "istio-reader"
	// clean_resources_by_label "clusterrolebinding" "app=istiod"
	// clean_resources_by_label "clusterrolebinding" "app.kubernetes.io/part-of=istio"
	// clean_resources_by_label "clusterrolebinding" "heritage=Tiller,release=istiod"

	// # Clean up ClusterRoles
	// echo "Cleaning up ClusterRoles related to Istio..."
	// clean_resources_by_pattern "clusterrole" "^istio-"
	// clean_resources_by_label "clusterrole" "app=istiod"
	// clean_resources_by_label "clusterrole" "app.kubernetes.io/part-of=istio"

	// # Clean up ValidatingWebhookConfigurations
	// echo "Cleaning up ValidatingWebhookConfigurations related to Istio..."
	// clean_resources_by_pattern "validatingwebhookconfiguration" "istio"
	// clean_resources_by_pattern "validatingwebhookconfiguration" "istiod"

	// # Clean up MutatingWebhookConfigurations
	// echo "Cleaning up MutatingWebhookConfigurations related to Istio..."
	// clean_resources_by_pattern "mutatingwebhookconfiguration" "istio"
	// clean_resources_by_pattern "mutatingwebhookconfiguration" "sidecar-injector"

	// # Clean up deployments and services in specified namespace
	// echo "Cleaning up leftover deployments in $NAMESPACE namespace..."
	// clean_resources_by_pattern "deployment" "istiod" "istio-system"
	// clean_resources_by_pattern "service" "istiod" "istio-system"

	// echo "Cleanup complete!"
	// `

	// 	// Create a ConfigMap to store the cleanup script
	// 	cleanupCm, err := corev1.NewConfigMap(ctx, cleanupCmName, &corev1.ConfigMapArgs{
	// 		Metadata: &metav1.ObjectMetaArgs{
	// 			Name:      pulumi.String(cleanupCmName),
	// 			Namespace: pulumi.String(namespace),
	// 		},
	// 		Data: pulumi.StringMap{
	// 			"cleanup.sh": pulumi.String(cleanupScript),
	// 		},
	// 	}, pulumi.Provider(provider))

	// 	if err != nil {
	// 		return err
	// 	}

	// 	// Run the cleanup script using pod with host service account
	// 	cleanupJobName := "istiod-cleanup-job"
	// 	cleanupPod, err := corev1.NewPod(ctx, cleanupJobName, &corev1.PodArgs{
	// 		Metadata: &metav1.ObjectMetaArgs{
	// 			Name:      pulumi.String(cleanupJobName),
	// 			Namespace: pulumi.String(namespace),
	// 		},
	// 		Spec: &corev1.PodSpecArgs{
	// 			RestartPolicy: pulumi.String("Never"),
	// 			Containers: corev1.ContainerArray{
	// 				&corev1.ContainerArgs{
	// 					Name:  pulumi.String("cleanup"),
	// 					Image: pulumi.String("bitnami/kubectl:latest"),
	// 					Command: pulumi.StringArray{
	// 						pulumi.String("sh"),
	// 						pulumi.String("-c"),
	// 						pulumi.String(`
	// # Run the cleanup script
	// sh /scripts/cleanup.sh

	// # Instead of a separate wait pod, just sleep to ensure the resources are properly removed
	// echo "Sleeping for 15 seconds to ensure cleanup completes..."
	// sleep 15
	// echo "Cleanup and wait complete, ready to proceed with installation"
	// `),
	// 					},
	// 					VolumeMounts: corev1.VolumeMountArray{
	// 						&corev1.VolumeMountArgs{
	// 							Name:      pulumi.String("cleanup-script"),
	// 							MountPath: pulumi.String("/scripts"),
	// 						},
	// 					},
	// 				},
	// 			},
	// 			Volumes: corev1.VolumeArray{
	// 				&corev1.VolumeArgs{
	// 					Name: pulumi.String("cleanup-script"),
	// 					ConfigMap: &corev1.ConfigMapVolumeSourceArgs{
	// 						Name:        pulumi.String(cleanupCmName),
	// 						DefaultMode: pulumi.Int(0755),
	// 					},
	// 				},
	// 			},
	// 			// Use the default service account which has the appropriate service account token
	// 			ServiceAccountName: pulumi.String("default"),
	// 			HostNetwork:        pulumi.Bool(true),
	// 			DnsPolicy:          pulumi.String("ClusterFirstWithHostNet"),
	// 		},
	// 	}, pulumi.Provider(provider), pulumi.DependsOn([]pulumi.Resource{cleanupCm, istioCNI}))

	// 	if err != nil {
	// 		return err
	// 	}

	// Export output
	ctx.Export("istioNamespace", pulumi.String(namespace))
	ctx.Export("istioBase", istioBase)
	ctx.Export("istioCNI", istioCNI)
	ctx.Export("istiod", istiod)
	ctx.Export("istioIngressGateway", istioIngressGateway)

	return err
}
