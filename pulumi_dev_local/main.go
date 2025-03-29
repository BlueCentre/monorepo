package main

import (
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"

	// config package might not be needed anymore if utils.NewConfig handles it
	// "github.com/pulumi/pulumi/sdk/v3/go/pulumi/config"

	"github.com/james/monorepo/pulumi_dev_local/pkg/applications"
	"github.com/james/monorepo/pulumi_dev_local/pkg/utils" // Import utils package
)

func main() {
	pulumi.Run(func(ctx *pulumi.Context) error {
		// Create PulumiConfig wrapper - this handles loading config
		pulumiConf := utils.NewConfig(ctx) // Correct way to initialize

		k8sContext := pulumiConf.GetString("kubernetes_context", "colima") // Use wrapper method

		// Create a Kubernetes provider instance
		k8sProvider, err := kubernetes.NewProvider(ctx, "k8s-provider", &kubernetes.ProviderArgs{
			Context: pulumi.String(k8sContext),
		})
		if err != nil {
			return err
		}

		// Get configuration values using the wrapper
		certManagerEnabled := pulumiConf.GetBool("cert_manager_enabled", false)
		externalSecretsEnabled := pulumiConf.GetBool("external_secrets_enabled", false)
		externalDnsEnabled := pulumiConf.GetBool("external_dns_enabled", false)
		opentelemetryEnabled := pulumiConf.GetBool("opentelemetry_enabled", false)
		datadogEnabled := pulumiConf.GetBool("datadog_enabled", false)
		istioEnabled := pulumiConf.GetBool("istio_enabled", false)
		redisEnabled := pulumiConf.GetBool("redis_enabled", false)
		cnpgEnabled := pulumiConf.GetBool("cnpg_enabled", false)
		mongodbEnabled := pulumiConf.GetBool("mongodb_enabled", false)
		databaseEnabled := pulumiConf.GetBool("database_enabled", false)
		ingressEnabled := pulumiConf.GetBool("ingress_controller_enabled", false)
		argocdEnabled := pulumiConf.GetBool("argocd_enabled", false)
		telepresenceEnabled := pulumiConf.GetBool("telepresence_enabled", false)

		// Setup base components
		var certManagerRelease pulumi.Resource

		if certManagerEnabled {
			var certManagerErr error
			certManagerRelease, certManagerErr = applications.DeployCertManager(ctx, k8sProvider)
			if certManagerErr != nil {
				return certManagerErr
			}
		}

		if externalSecretsEnabled {
			// Deploy External Secrets first
			if err := applications.DeployExternalSecrets(ctx, k8sProvider); err != nil {
				return err
			}

			// Create a delay to ensure the webhooks are ready
			// _, err = applications.AddDelay(ctx, 30*time.Second)
			// if err != nil {
			// 	return err
			// }

			// Deploy the ClusterSecretStore after ExternalSecrets is deployed
			// if err := applications.DeployExternalSecretsStore(ctx, k8sProvider); err != nil {
			// 	return err
			// }
		}

		// Deploy external-dns (it will handle external-secrets dependency internally)
		if externalDnsEnabled {
			if err := applications.DeployExternalDNS(ctx, k8sProvider); err != nil {
				return err
			}
		}

		// OpenTelemetry setup
		if opentelemetryEnabled {
			if err := applications.DeployOpenTelemetry(ctx, k8sProvider, certManagerRelease); err != nil {
				return err
			}

			if err := applications.DeployMonitoringStack(ctx, k8sProvider); err != nil {
				return err
			}
		}

		// Datadog setup
		if datadogEnabled {
			if _, err := applications.DeployDatadog(ctx, k8sProvider); err != nil {
				return err
			}
		}

		// Service mesh setup
		if istioEnabled {
			if err := applications.DeployIstio(ctx, k8sProvider); err != nil {
				return err
			}
		}

		// Redis setup for both Istio rate limiting and application usage
		if redisEnabled {
			if _, err := applications.DeployRedis(ctx, k8sProvider); err != nil {
				return err
			}
		}

		// CloudNativePG setup
		if cnpgEnabled {
			// First, deploy the operator itself
			// Store the returned resource to use as a dependency for the cluster
			cnpgOperatorRelease, opErr := applications.DeployCloudNativePGOperator(ctx, k8sProvider)
			if opErr != nil {
				return opErr
			}
			// After the operator is deployed (and potentially waited for), deploy the cluster chart
			// Pass the operator release resource as a dependency
			_, clusterErr := applications.DeployCnpgCluster(ctx, k8sProvider, cnpgOperatorRelease)
			if clusterErr != nil {
				return clusterErr
			}
		}

		// MongoDB setup for application usage
		if mongodbEnabled {
			if _, err := applications.DeployMongoDB(ctx, k8sProvider); err != nil {
				return err
			}
		}

		// Database setup
		if databaseEnabled {
			if err := applications.DeployDatabase(ctx, k8sProvider); err != nil {
				return err
			}
		}

		// Ingress setup
		if ingressEnabled {
			if err := applications.DeployIngressController(ctx, k8sProvider); err != nil {
				return err
			}
		}

		// GitOps setup
		if argocdEnabled {
			if err := applications.DeployArgoCD(ctx, k8sProvider); err != nil {
				return err
			}
		}

		// Deploy other components that don't depend on external-secrets
		if telepresenceEnabled {
			if err := applications.DeployTelepresence(ctx, k8sProvider); err != nil {
				return err
			}
		}

		return nil
	})
}
