resource "google_container_cluster" "kubernetes_cluster" {
  count    = var.disable ? 0 : 1
  provider = google-beta # Must use `google-beta` provider to use GKE Usage Metering

  name                      = var.name
  project                   = var.project_id
  location                  = local.location
  network                   = var.vpc_network_self_link
  subnetwork                = local.subnetwork_self_link
  networking_mode           = var.networking_mode
  remove_default_node_pool  = local.remove_default_node_pool
  initial_node_count        = local.initial_node_count
  default_max_pods_per_node = local.default_max_pods_per_node
  enable_legacy_abac        = var.enable_legacy_abac
  deletion_protection       = false


  # GKE Usage Metering
  # resource_usage_export_config {
  #   enable_network_egress_metering = var.enable_network_egress_metering
  #   bigquery_destination {
  #     dataset_id = var.gke_usage_metering_dataset_id
  #   }
  # }

  release_channel {
    channel = var.release_channel
  }

  dynamic "ip_allocation_policy" {
    for_each = local.ip_allocation_policy
    content {
      cluster_ipv4_cidr_block       = local.cluster_ipv4_cidr_block
      services_ipv4_cidr_block      = local.services_ipv4_cidr_block
      cluster_secondary_range_name  = local.cluster_secondary_range_name
      services_secondary_range_name = local.services_secondary_range_name
    }
  }

  # maintenance_policy {
  #   recurring_window {
  #     start_time = var.maintenance_recurring_window.start_time
  #     end_time   = var.maintenance_recurring_window.end_time
  #     recurrence = var.maintenance_recurring_window.recurrence
  #   }
  # }

  # notification_config {
  #   pubsub {
  #     enabled = var.notification_config_topic != "" ? true : false
  #     topic   = var.notification_config_topic
  #   }
  # }

  dynamic "private_cluster_config" {
    for_each = var.enable_private_nodes ? [{
      enable_private_nodes        = var.enable_private_nodes,
      enable_private_endpoint     = var.enable_private_endpoint
      master_ipv4_cidr_block      = var.master_ipv4_cidr_block
      private_endpoint_subnetwork = var.private_endpoint_subnetwork
    }] : []

    content {
      enable_private_endpoint     = private_cluster_config.value.enable_private_endpoint
      enable_private_nodes        = private_cluster_config.value.enable_private_nodes
      master_ipv4_cidr_block      = private_cluster_config.value.master_ipv4_cidr_block
      private_endpoint_subnetwork = private_cluster_config.value.private_endpoint_subnetwork
      dynamic "master_global_access_config" {
        for_each = var.master_global_access_enabled ? [var.master_global_access_enabled] : []
        content {
          enabled = master_global_access_config.value
        }
      }
    }
  }

  dynamic "workload_identity_config" {
    for_each = local.workload_identity_enabled
    content {
      workload_pool = "${var.project_id}.svc.id.goog"
    }
  }

  dynamic "addons_config" {
    for_each = local.filestore_csi_enabled
    content {
      gcp_filestore_csi_driver_config {
        enabled = true
      }
    }
  }

  resource_labels = local.labels
}

module "gke_auth" {
  count                = var.disable ? 0 : 1
  source               = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  project_id           = var.project_id
  cluster_name         = google_container_cluster.kubernetes_cluster[0].name # var.name
  location             = local.location
  use_private_endpoint = false
  depends_on = [
    google_container_cluster.kubernetes_cluster
  ]
}
