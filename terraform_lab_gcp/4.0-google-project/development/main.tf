locals {
  active   = var.teardown ? false : true
  env_list = toset(["dev"])
  env_code = substr(var.environment, 0, 1)
  env_short = {
    "development"   = "dev",
    "nonproduction" = "stg",
    "production"    = "prd"
  }
  is_dev_bool = var.environment == "development" ? true : false
  is_prd_bool = var.environment == "production" ? true : false
}

module "naming" {
  source      = "app.terraform.io/example/modules/example//modules/naming"
  version     = "0.8.0"
  environment = local.env_short[var.environment]
  region      = var.project_region
  name        = var.stack
  product     = var.stack
  stack       = var.stack
  tenant      = var.tenant
  owner       = "james_dot_nguyen"
}

# resource "random_pet" "pet" {}

# resource "random_string" "suffix" {
#   length  = 4
#   special = false
#   upper   = false
#   numeric = false
# }
