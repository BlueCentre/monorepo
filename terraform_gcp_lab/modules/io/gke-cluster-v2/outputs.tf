output "name" {
  value = (
    var.disable ?
    null :
    google_container_cluster.kubernetes_cluster[0].name
  )
}

output "location" {
  value = (
    var.disable ?
    null :
    google_container_cluster.kubernetes_cluster[0].location
  )
}

output "endpoint" {
  value = (
    var.disable ?
    null :
    google_container_cluster.kubernetes_cluster[0].endpoint
  )
}

output "master_version" {
  value = (
    var.disable ?
    null :
    google_container_cluster.kubernetes_cluster[0].master_version
  )
}

# output "gke_auth" {
#   sensitive = true
#   value = (

#     var.disable ?
#     {
#       cluster_ca = null
#       host       = null
#       token      = null
#     } :
#     {
#       cluster_ca = module.gke_auth[0].cluster_ca_certificate
#       host       = module.gke_auth[0].host
#       token      = module.gke_auth[0].token
#     }
#   )
# }

//output "gke_usage_metering_dataset_id" {
//  value = (
//    var.disable ?
//    null :
//    google_container_cluster.kubernetes_cluster[0].resource_usage_export_config[0].bigquery_destination[0].dataset_id
//  )
//}
