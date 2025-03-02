variable "name" {
  type        = string
  description = "The name of this GKE cluster"
}

variable "project_id" {
  type        = string
  description = "The GCP project (string ID) this cluster will be created in"
}

variable "gke_usage_metering_dataset_id" {
  type        = string
  description = "The ID of the Bigquery Dataset to export usage metering data to"
  default     = null
}

variable "region" {
  type        = string
  description = "The GCP region this GKE cluster will be located in. Either 'region' or 'zone' must be non-null. If 'region' is submitted, cluster will be REGIONAL. If both are provided, 'region' overrides 'zone'"
  default     = null
}

variable "zone" {
  type        = string
  description = "The GCP zone this GKE cluster will be located in. Either 'region' or 'zone' must be non-null. If 'zone' is submitted, cluster will be ZONAL. If both are provided, 'zone' is overriden by 'region'"
  default     = null
}

variable "enable_legacy_abac" {
  type        = bool
  description = "Whether the ABAC authorizer is enabled for this cluster"
  default     = true
}

variable "enable_network_egress_metering" {
  type        = string
  description = "Whether to enable network egress metering for the resource usage export"
  default     = false
}

variable "release_channel" {
  type        = string
  default     = "STABLE"
  description = "Configuration options for the Release channel feature. Allowed values: UNSPECIFIED, RAPID, REGULAR, STABLE."
}

variable "vpc_network_self_link" {
  type        = string
  description = "The URI of the network to use for this GKE instance"
  default     = null
}

variable "vpc_subnetwork_self_link" {
  type        = string
  description = "The URI of the network to use for this GKE instance"
  default     = null
}

variable "use_shared_network" {
  type        = bool
  description = "When set to true when cluster network is shared network."
  default     = false
}

variable "default_max_pods_per_node" {
  type        = number
  description = "The default maximum number of pods per node in this cluster."
  default     = 110
}

variable "cluster_ipv4_cidr_block" {
  type        = string
  description = "The IP address range for the cluster pod IPs."
  default     = "/14"
}

variable "services_ipv4_cidr_block" {
  type        = string
  description = "The IP address range of the services IPs in this cluster."
  default     = "/20"
}

variable "cluster_secondary_range_name" {
  type        = string
  description = "The name of the existing secondary range in the cluster's subnetwork to use for pod IP addresses. Set for existing range_name when using shared network."
  default     = null
}

variable "services_secondary_range_name" {
  type        = string
  description = "The name of the existing secondary range in the cluster's subnetwork to use for service ClusterIPs. Set for existing range_name when using shared network"
  default     = null
}

variable "environment" {
  type        = string
  description = "The environment this GKE cluster will store data for. This should be one of: [null, 'sandbox', 'dev', 'staging', 'integ', 'prod']"
  default     = null
}

variable "owner" {
  type        = string
  description = "The huwan owning this GKE cluster."
}

variable "team" {
  type        = string
  description = "The team owning this GKE cluster."
}

variable "custom_labels" {
  type        = map(string)
  description = "Custom labels to set on the GKE cluster"
  default     = {}
}

variable "notification_config_topic" {
  type        = string
  description = "The desired Pub/Sub topic to which notifications will be sent by GKE. Format is projects/{project}/topics/{topic}."
  default     = ""
}

variable "networking_mode" {
  type        = string
  default     = "VPC_NATIVE"
  description = "ROUTES or VPC_NATIVE"
}

variable "maintenance_recurring_window" {
  # type        = map(string)
  type = object({
    start_time = string,
    end_time   = string,
    recurrence = string
  })
  description = <<EOF
  Custom maintenance policy recurring window to set on the GKE cluster, i.e.
  {
    start_time = "2019-01-01T09:00:00Z"
    end_time = "2019-01-01T17:00:00Z"
    recurrence = "FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR"
  }
  EOF
  default = null
}

variable "workload_identity_enabled" {
  description = "Enable Workload Identity"
  type        = bool
  default     = false
}

variable "filestore_csi_enabled" {
  description = "Enable Filestore CSI Driver for GKE"
  type        = bool
  default     = false
}

# ---------------------------------------------------------------------------------------------------------------------
# DISABLE MODULE
# Terraform does not allow the count parameter for modules
# This is a workaround to allow the caller of the module to
# optionally disable the creation of this module's resource
# For example:
# disable = true
# ---------------------------------------------------------------------------------------------------------------------

variable "disable" {
  description = "Disable the resources created by this module"
  type        = bool
  default     = false
}
