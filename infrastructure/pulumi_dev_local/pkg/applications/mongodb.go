package applications

import (
	"github.com/james/monorepo/pulumi_dev_local/pkg/resources"
	"github.com/james/monorepo/pulumi_dev_local/pkg/utils"
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes"
	corev1 "github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/core/v1"
	metav1 "github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/meta/v1"

	// "github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/yaml" // Commented out as yaml.NewConfigGroup is no longer used
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

	// Deploy MongoDB Community Operator CRDs chart first
	mongodbOperatorCRDs, err := resources.DeployHelmChart(ctx, provider, resources.HelmChartConfig{
		Name:            "mongodb-operator-crds",
		ChartName:       "community-operator-crds",
		Version:         cfg.GetString("mongodb_operator_version", "0.12.0"), // Use same version as operator for consistency
		RepositoryURL:   "https://mongodb.github.io/helm-charts",
		Namespace:       namespace,
		CreateNamespace: true, // Let Helm create the namespace if it doesn't exist
		// No specific values needed for CRDs chart usually
	})
	if err != nil {
		return nil, err
	}

	// Create MongoDB password secret *after* CRDs chart (which creates namespace), but *before* operator chart.
	mongoPasswordSecret, err := corev1.NewSecret(ctx, "mongodb-password", &corev1.SecretArgs{
		Metadata: &metav1.ObjectMetaArgs{
			Name:      pulumi.String("mongodb-password"),
			Namespace: pulumi.String(namespace),
		},
		StringData: pulumi.StringMap{
			"password": pulumi.String(mongodbPassword),
		},
		// Depend on the CRD release to ensure namespace exists
	}, pulumi.Provider(provider), pulumi.DependsOn([]pulumi.Resource{mongodbOperatorCRDs}))
	if err != nil {
		return nil, err
	}

	// Deploy MongoDB Community Operator chart
	// Assign to _ as mongodbOperator variable is not used elsewhere.
	_, err = resources.DeployHelmChart(ctx, provider, resources.HelmChartConfig{
		Name:            "mongodb-operator",
		ChartName:       "community-operator",
		Version:         cfg.GetString("mongodb_operator_version", "0.12.0"),
		RepositoryURL:   "https://mongodb.github.io/helm-charts",
		Namespace:       namespace,
		CreateNamespace: false, // Namespace should be created by CRDs chart or exist
		ValuesFile:      "mongodb-community-operator",
		Values: map[string]interface{}{
			"community-operator-crds": map[string]interface{}{
				"enabled": false,
			},
			"createResource": false,
			"resource": map[string]interface{}{
				"name":    cfg.GetString("mongodb_replicaset_name", "mongodb-rs"),
				"version": cfg.GetString("mongodb_replicaset_version", "4.4.19"),
				"members": cfg.GetInt("mongodb_replicaset_members", 1),
			},
		},
		// Operator depends on CRDs and the secret existing.
	}, pulumi.DependsOn([]pulumi.Resource{mongodbOperatorCRDs, mongoPasswordSecret}))
	if err != nil {
		return nil, err
	}

	// Create MongoDB Community custom resource
	// This is now commented out as the operator chart value 'mongodbCommunity.create' is set to false.
	// The MongoDBCommunity resource should be managed separately if needed.
	/*
			mongodbCRyaml := `
		apiVersion: mongodbcommunity.mongodb.com/v1
		kind: MongoDBCommunity
		metadata:
		  name: mongodb-rs
		  namespace: ` + namespace + `
		spec:
		  members: 1
		  type: ReplicaSet
		  version: ` + cfg.GetString("mongodb_replicaset_version", "4.4.19") + `
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
				YAML: []pulumi.StringInput{pulumi.String(mongodbCRyaml)}, // Use YAML string directly
			}, pulumi.Provider(provider), pulumi.DependsOn([]pulumi.Resource{mongoPasswordSecret}))

			if err != nil {
				return nil, err
			}
	*/

	// Return with the namespace resource (using CRDs release as the representative namespace creator)
	return &ApplicationDeployment{
		Namespace: mongodbOperatorCRDs, // Use CRDs release as it handles namespace creation
		Services: pulumi.StringArray{
			pulumi.String("mongodb"),
		},
		// YAML list is now empty as the resource creation is disabled/commented out
		YAML: []string{},
	}, nil
}
