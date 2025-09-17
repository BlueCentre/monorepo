package project_api_services

import (
	"github.com/pulumi/pulumi-gcp/sdk/v7/go/gcp/projects"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

// EnableAPIServicesArgs defines the arguments for enabling API services.
type EnableAPIServicesArgs struct {
	ProjectID string
	Services  []string
}

// EnableAPIServices enables a list of specified API services for a GCP project.
// It returns a map of service names to their corresponding projects.Service resources.
func EnableAPIServices(ctx *pulumi.Context, name string, args *EnableAPIServicesArgs) (map[string]*projects.Service, error) {
	enabledServices := make(map[string]*projects.Service)
	for _, service := range args.Services {
		svc, err := projects.NewService(ctx, name+"-"+service, &projects.ServiceArgs{
			Project: pulumi.String(args.ProjectID),
			Service: pulumi.String(service),
			DisableOnDestroy: pulumi.Bool(false), // Keep API enabled even if Pulumi stack is destroyed
		})
		if err != nil {
			return nil, err
		}
		enabledServices[service] = svc
	}
	return enabledServices, nil
}