# output "bucket" {
#   value = module.gcs_buckets.bucket
# }

# output "buckets" {
#   value = module.gcs_buckets.buckets
# }

# output "buckets_map" {
#   value = module.gcs_buckets.buckets_map
# }

# output "buckets_names_list" {
#   value = module.gcs_buckets.names_list
# }

output "seed_bucket" {
  value = module.gcs_buckets.buckets_map["prj-b-seed-tfstate"].name
}

output "google_project_bucket" {
  value = module.gcs_buckets.buckets_map["prj-b-seed-gcp-project-tfstate"].name
}

output "google_region_bucket" {
  value = module.gcs_buckets.buckets_map["prj-b-seed-gcp-region-tfstate"].name
}

output "google_zone_bucket" {
  value = module.gcs_buckets.buckets_map["prj-b-seed-gcp-zone-tfstate"].name
}

output "google_container_cluster_bucket" {
  value = module.gcs_buckets.buckets_map["prj-b-seed-gcp-container-cluster-tfstate"].name
}

output "kubernetes_apps_bucket" {
  value = module.gcs_buckets.buckets_map["prj-b-seed-k8s-apps-tfstate"].name
}


output "common_config" {
  value = {
    default_region_1 = var.project_primary_region
    default_region_2 = var.project_secondary_region
    # folder_prefix = var.folder_prefix
    # parent_id = var.project_id
    # bootstrap_folder_name = var.project_prefix
  }
}
