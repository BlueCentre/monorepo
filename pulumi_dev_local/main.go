package main

import (
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi/config"

	"github.com/james/monorepo/pulumi_dev_local/pkg/applications"
)

func main() {
	pulumi.Run(func(ctx *pulumi.Context) error {
		// Load configuration
		conf := config.New(ctx, "dev-local-infrastructure")
		k8sContext := conf.Get("kubernetes_context")
		if k8sContext == "" {
			k8sContext = "colima" // Default to colima if not specified
		}

		// Create a Kubernetes provider instance
		k8sProvider, err := kubernetes.NewProvider(ctx, "k8s-provider", &kubernetes.ProviderArgs{
			Context: pulumi.String(k8sContext),
		})
		if err != nil {
			return err
		}

		// Get configuration values
		certManagerEnabled := conf.GetBool("cert_manager_enabled")
		externalSecretsEnabled := conf.GetBool("external_secrets_enabled")
		externalDnsEnabled := conf.GetBool("external_dns_enabled")
		opentelemetryEnabled := conf.GetBool("opentelemetry_enabled")
		datadogEnabled := conf.GetBool("datadog_enabled")
		istioEnabled := conf.GetBool("istio_enabled")
		databaseEnabled := conf.GetBool("database_enabled")
		ingressEnabled := conf.GetBool("ingress_controller_enabled")
		argocdEnabled := conf.GetBool("argocd_enabled")
		telepresenceEnabled := conf.GetBool("telepresence_enabled")
		cnpgEnabled := conf.GetBool("cnpg_enabled")
		redisEnabled := conf.GetBool("redis_enabled")

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

		// Database setup
		if databaseEnabled {
			if err := applications.DeployDatabase(ctx, k8sProvider); err != nil {
				return err
			}
		}

		// CloudNativePG setup
		if cnpgEnabled {
			if _, err := applications.DeployCloudNativePG(ctx, k8sProvider); err != nil {
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
