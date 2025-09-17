package iam

import (
	"github.com/pulumi/pulumi-gcp/sdk/v7/go/gcp/projects"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

// GrantIAMRoleArgs defines the arguments for granting an IAM role to a member.
type GrantIAMRoleArgs struct {
	ProjectID string
	Member    string // e.g., "user:your-email@example.com"
	Role      string // e.g., "roles/viewer"
}

// GrantIAMRole grants a specified IAM role to a member on a GCP project.
func GrantIAMRole(ctx *pulumi.Context, name string, args *GrantIAMRoleArgs) error {
	_, err := projects.NewIAMMember(ctx, name, &projects.IAMMemberArgs{
		Project: pulumi.String(args.ProjectID),
		Role:    pulumi.String(args.Role),
		Member:  pulumi.String(args.Member),
	})
	if err != nil {
		return err
	}
	return nil
}
