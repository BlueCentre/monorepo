terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.83.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.1.1"
    }
  }
  required_version = ">= 0.14"
}