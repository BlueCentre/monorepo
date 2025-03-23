# Development tools used in this repository

1. Colima for local kubernetes cluster management on macos
2. Bazel for building, testing and packaging docker images
3. Skaffold for application development workflow orchestration and a replacement for docker-compose
4. Terraform for infrastructure as code using HCL
5. Pulumi for infrastructure as code using general-purpose programming languages (Go)
6. Sonarcube is used for code quality assurance
7. Always use best practice and latest versions for these tools
8. Never downgrade schema or tool versions to resolve issues
9. Never deviate from our defined guidance or architecture without confirmation 

# Workflows

## Application Development Workflow
- Bazel is used for building, testing and packaging docker images
- Skaffold is used for development mode and deployments as a replacement for docker-compose
- All applications are deployed to Kubernetes using Skaffold

## Infrastructure as Code Workflow
- Terraform and Pulumi use their own native workflows
- Infrastructure as code does NOT use Skaffold or Bazel
- Terraform workflows: init → plan → apply → output/verify → destroy (when needed)
- Pulumi workflows: stack init → preview → up → stack output/verify → destroy (when needed)
- Both Terraform and Pulumi can use Helm to deploy resources to Kubernetes

# Repository & prompt objectives

1. For application development, use skaffold <build,test,run,verify,exec> to update kubernetes resources
2. For infrastructure as code, use terraform or pulumi directly with their native workflows
3. Always build, test, run and verify end-to-end after any code changes
4. Once everything works, always update the relevant root and application README files
5. Clean up any unused code or configurations that are not used or part of the change in order to keep the repository maintainable
6. Colima can be restarted when kubernetes is unresponsive, but never modify colima configurations 