package applications

import (
	"github.com/james/monorepo/pulumi_dev_local/pkg/resources"
	"github.com/james/monorepo/pulumi_dev_local/pkg/utils"
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes"
	corev1 "github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/core/v1"
	metav1 "github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/meta/v1"
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/yaml"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

// ApplicationDeployment represents a deployed application with its namespace and related resources
type ApplicationDeployment struct {
	Namespace pulumi.Resource
	Services  pulumi.StringArray
	YAML      []string
}

// DeployMongoDB deploys the MongoDB Community Operator and a MongoDB replicaset
func DeployMongoDB(ctx *pulumi.Context, provider *kubernetes.Provider) (*ApplicationDeployment, error) {
	// Use config utils implementation
	cfg := utils.NewConfig(ctx)

	// Check if MongoDB is enabled, early return if not
	if !cfg.GetBool("mongodb_enabled", false) {
		return nil, nil
	}

	// Get MongoDB password from config
	mongodbPassword := cfg.GetString("mongodb_password", "mongodb-password")
	namespace := "mongodb"

	// Deploy MongoDB Community Operator chart (with namespace creation)
	mongodbOperator, err := resources.DeployHelmChart(ctx, provider, resources.HelmChartConfig{
		Name:            "mongodb-operator",
		ChartName:       "community-operator",
		Version:         "0.8.3",
		RepositoryURL:   "https://mongodb.github.io/helm-charts",
		Namespace:       namespace,
		CreateNamespace: true, // Let Helm create the namespace
		Values: map[string]interface{}{
			"operator": map[string]interface{}{
				"watchNamespace": namespace,
			},
			"createResource": false, // We'll create the MongoDB CR manually
		},
	})
	if err != nil {
		return nil, err
	}

	// Create MongoDB password secret after namespace exists
	mongoPasswordSecret, err := corev1.NewSecret(ctx, "mongodb-password", &corev1.SecretArgs{
		Metadata: &metav1.ObjectMetaArgs{
			Name:      pulumi.String("mongodb-password"),
			Namespace: pulumi.String(namespace),
		},
		StringData: pulumi.StringMap{
			"password": pulumi.String(mongodbPassword),
		},
	}, pulumi.Provider(provider), pulumi.DependsOn([]pulumi.Resource{mongodbOperator}))
	if err != nil {
		return nil, err
	}

	// Create MongoDB Community custom resource
	mongodbCRyaml := `
apiVersion: mongodbcommunity.mongodb.com/v1
kind: MongoDBCommunity
metadata:
  name: mongodb-rs
  namespace: ` + namespace + `
spec:
  members: 1
  type: ReplicaSet
  version: "4.4.19"
  featureCompatibilityVersion: "4.4"
  security:
    authentication:
      modes: ["SCRAM"]
  users:
    - name: root
      db: admin
      passwordSecretRef:
        name: mongodb-password
      roles:
        - name: readWriteAnyDatabase
          db: admin
      scramCredentialsSecretName: mongodb-scram
  statefulSet:
    spec:
      serviceName: mongodb-svc
      selector:
        matchLabels:
          app: mongodb-svc
      template:
        metadata:
          labels:
            app: mongodb-svc
      volumeClaimTemplates:
        - metadata:
            name: data-volume
          spec:
            accessModes: ["ReadWriteOnce"]
            resources:
              requests:
                storage: 8Gi
`

	// Deploy the MongoDB Community CR with YAML
	_, err = yaml.NewConfigGroup(ctx, "mongodb-community", &yaml.ConfigGroupArgs{
		YAML: []string{mongodbCRyaml},
	}, pulumi.Provider(provider), pulumi.DependsOn([]pulumi.Resource{mongoPasswordSecret}))

	if err != nil {
		return nil, err
	}

	// Return with the namespace resource
	return &ApplicationDeployment{
		Namespace: mongodbOperator,
		Services: pulumi.StringArray{
			pulumi.String("mongodb"),
		},
		YAML: []string{
			mongodbCRyaml,
		},
	}, nil
}
