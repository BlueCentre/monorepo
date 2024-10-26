terraform {
  required_version = ">= 0.13"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.50, != 4.31.0"
    }

    googleworkspace = {
      source  = "hashicorp/googleworkspace"
      version = "0.7.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }

    # Un-comment gitlab required_providers when using gitlab CI/CD
    # gitlab = {
    #   source  = "gitlabhq/gitlab"
    #   version = "16.6.0"
    # }

    # Un-comment github required_providers when using GitHub Actions
    # github = {
    #   source  = "integrations/github"
    #   version = "5.34.0"
    # }

    # Un-comment tfe required_providers when using Terraform Cloud
    # tfe = {
    #   source  = "hashicorp/tfe"
    #   version = "0.48.0"
    # }

    # auth0 = {
    #   source  = "auth0/auth0"
    #   version = ">= 1.0.0"
    # }

    # datadog = {
    #   source  = "DataDog/datadog"
    #   version = "3.39.0"
    # }
  }
}
