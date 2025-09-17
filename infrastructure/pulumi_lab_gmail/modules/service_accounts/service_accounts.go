package service_accounts

import (
	"github.com/pulumi/pulumi-gcp/sdk/v7/go/gcp/serviceaccount"
	"github.com/pulumi/pulumi-gcp/sdk/v7/go/gcp/projects"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

// CreateServiceAccountArgs defines the arguments for creating a service account and granting roles.
type CreateServiceAccountArgs struct {
	ProjectID string
	AccountID string
	DisplayName string
	Roles     []string
}

// CreateServiceAccount creates a new Google Cloud Service Account and grants specified roles.
func CreateServiceAccount(ctx *pulumi.Context, name string, args *CreateServiceAccountArgs) (*serviceaccount.Account, error) {
	sa, err := serviceaccount.NewAccount(ctx, name, &serviceaccount.AccountArgs{
		Project:     pulumi.String(args.ProjectID),
		AccountId:   pulumi.String(args.AccountID),
		DisplayName: pulumi.String(args.DisplayName),
	})
	if err != nil {
		return nil, err
	}

	for _, role := range args.Roles {
		_, err := projects.NewIAMMember(ctx, name+"-"+role, &projects.IAMMemberArgs{
			Project: pulumi.String(args.ProjectID),
			Role:    pulumi.String(role),
			Member:  pulumi.Sprintf("serviceAccount:%s", sa.Email),
		})
		if err != nil {
			return nil, err
		}
	}

	ctx.Export(name+"Email", sa.Email)

	return sa, nil
}
