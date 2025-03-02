resource "google_container_node_pool" "node_pool" {
  count = var.disable ? 0 : 1

  name     = var.name
  project  = var.project_id
  cluster  = var.gke_cluster_name
  location = var.gke_cluster_location

  initial_node_count = var.initial_node_count


  node_config {
    disk_size_gb = var.disk_size_gb
    disk_type    = local.disk_type
    machine_type = local.machine_type
    preemptible  = var.preemptible
    image_type   = local.image_type

    service_account = var.service_account
    oauth_scopes    = local.oauth_scopes

    metadata = local.metadata

    workload_metadata_config {
      mode = local.workload_metadata_config
    }

    labels = local.labels

    dynamic "taint" {
      for_each = var.taints

      content {
        effect = upper(taint.value.effect)
        key    = taint.value.key
        value  = taint.value.value
      }
    }
  }

  dynamic "autoscaling" {
    for_each = local.autoscaling_config_array

    content {
      min_node_count = autoscaling.value.autoscaling_min_size
      max_node_count = autoscaling.value.autoscaling_max_size
    }
  }

  management {
    auto_repair  = var.auto_repair_nodes
    auto_upgrade = var.auto_upgrade_nodes
  }
}
