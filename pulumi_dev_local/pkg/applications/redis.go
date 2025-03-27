package applications

import (
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes"
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/helm/v3"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi/config"
)

// DeployRedis deploys the Bitnami Redis Helm chart for both Istio rate limiting and application usage
func DeployRedis(ctx *pulumi.Context, provider *kubernetes.Provider) (pulumi.Resource, error) {
	cfg := config.New(ctx, "dev-local-infrastructure")

	redisPassword := cfg.Get("redis_password")
	if redisPassword == "" {
		redisPassword = "redis-password"
	}

	// Create Redis chart resource
	redisChart, err := helm.NewRelease(ctx, "redis", &helm.ReleaseArgs{
		Chart:   pulumi.String("redis"),
		Version: pulumi.String("18.19.1"), // Use specific version for consistency
		RepositoryOpts: &helm.RepositoryOptsArgs{
			Repo: pulumi.String("https://charts.bitnami.com/bitnami"),
		},
		Namespace:       pulumi.String("redis"),
		CreateNamespace: pulumi.Bool(true),
		Values: pulumi.Map{
			"global": pulumi.Map{
				"imageRegistry":    pulumi.String(""),
				"imagePullSecrets": pulumi.Array{},
				"storageClass":     pulumi.String(""),
			},
			"commonLabels": pulumi.Map{
				"app.kubernetes.io/part-of":    pulumi.String("platform-infrastructure"),
				"app.kubernetes.io/managed-by": pulumi.String("pulumi"),
			},
			"auth": pulumi.Map{
				"enabled":          pulumi.Bool(true),
				"sentinel":         pulumi.Bool(false),
				"usePasswordFiles": pulumi.Bool(false),
				"password":         pulumi.String(redisPassword),
			},
			"master": pulumi.Map{
				"persistence": pulumi.Map{
					"enabled":      pulumi.Bool(true),
					"size":         pulumi.String("8Gi"),
					"medium":       pulumi.String(""),
					"path":         pulumi.String("/data"),
					"storageClass": pulumi.String(""),
				},
				"service": pulumi.Map{
					"type": pulumi.String("ClusterIP"),
					"ports": pulumi.Map{
						"redis": pulumi.Int(6379),
					},
					"annotations": pulumi.Map{
						"app.kubernetes.io/purpose": pulumi.String("multi-tenant"),
					},
				},
				"resources": pulumi.Map{
					"requests": pulumi.Map{
						"memory": pulumi.String("256Mi"),
						"cpu":    pulumi.String("100m"),
					},
					"limits": pulumi.Map{
						"memory": pulumi.String("1Gi"),
						"cpu":    pulumi.String("500m"),
					},
				},
				"podSecurityContext": pulumi.Map{
					"fsGroup": pulumi.Int(1001),
				},
				"containerSecurityContext": pulumi.Map{
					"runAsUser": pulumi.Int(1001),
				},
			},
			"replica": pulumi.Map{
				"replicaCount": pulumi.Int(2),
				"persistence": pulumi.Map{
					"enabled": pulumi.Bool(true),
					"size":    pulumi.String("8Gi"),
				},
				"service": pulumi.Map{
					"type": pulumi.String("ClusterIP"),
					"ports": pulumi.Map{
						"redis": pulumi.Int(6379),
					},
					"annotations": pulumi.Map{
						"app.kubernetes.io/purpose": pulumi.String("multi-tenant"),
					},
				},
				"resources": pulumi.Map{
					"requests": pulumi.Map{
						"memory": pulumi.String("256Mi"),
						"cpu":    pulumi.String("100m"),
					},
					"limits": pulumi.Map{
						"memory": pulumi.String("1Gi"),
						"cpu":    pulumi.String("500m"),
					},
				},
			},
			"sentinel": pulumi.Map{
				"enabled":   pulumi.Bool(false),
				"masterSet": pulumi.String("mymaster"),
			},
			"metrics": pulumi.Map{
				"enabled": pulumi.Bool(true),
				"serviceMonitor": pulumi.Map{
					"enabled": pulumi.Bool(false),
				},
			},
			"networkPolicy": pulumi.Map{
				"enabled":       pulumi.Bool(true),
				"allowExternal": pulumi.Bool(true),
			},
			"commonConfiguration": pulumi.String("# Enable AOF persistence\nappendonly yes\n# Disable RDB persistence\nsave \"\"\n"),
		},
	}, pulumi.Provider(provider))

	if err != nil {
		return nil, err
	}

	return redisChart, nil
}
