locals {
  active            = var.teardown ? false : true
  env_list          = toset(["dev"])
  env_code          = substr(var.environment, 0, 1)
  is_dev_bool       = var.environment == "development" ? true : false
  is_prd_bool       = var.environment == "production" ? true : false
  is_primary_region = var.project_region == var.region ? true : false
}

module "region_naming" {
  source  = "terraform-google-modules/utils/google"
  version = "~> 0.7"
}

# output "region_short_name_map" {
#   description = "The 4 or 5 character shortname of any given region."
#   value       = module.region_naming.region_short_name_map[var.region]
# }
