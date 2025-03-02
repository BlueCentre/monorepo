variable "name" {
  type        = string
  description = "The name of this node pool"
}

variable "project_id" {
  type        = string
  description = "The GCP project (string ID) this cluster will be created in"
}

variable "gke_cluster_name" {
  type        = string
  description = "The name of the GKE cluster this node pool will be associated with"
}

variable "gke_cluster_location" {
  type        = string
  description = "The location (region or zone) of the GKE cluster this node pool will be associated with"
}

variable "initial_node_count" {
  type        = number
  description = "The initial number of nodes for the pool. In regional or multi-zonal clusters, this is the number of nodes per zone"
  default     = 1
}

variable "disk_size_gb" {
  type        = number
  description = "The initial disk size in GB for the each node in the node pool"
}

# See https://cloud.google.com/compute/docs/machine-types#predefined_machine_types for predefined GCP machine types
variable "machine_type" {
  type        = string
  description = "The predefined GCP machine type to use for each node. If 'num_cpus' and 'memory_size_mb' is provided, this value is ignored"
  default     = "n1-standard-8"
}

variable "num_cpus" {
  type        = number
  description = "The number of CPUs to use for each node. If 'memory_size_mb' is also provided, these values override the 'machine_type' variable"
  default     = null
}

variable "memory_size_mb" {
  type        = number
  description = "The number of MBs of memory to use for each node. If 'num_cpus' is also provided, these values override the 'machine_type' variable"
  default     = null
}

variable "disk_type" {
  type        = string
  description = "The type of disk used for this node pool. This should be one of: ['SSD', 'STANDARD ']"
  default     = "STANDARD"
}

variable "preemptible" {
  type        = bool
  description = "Whether the nodes in the node pool should be preemptible"
  default     = true
}

variable "autoscaling_min_size" {
  type        = number
  description = "The minimum number of nodes in the node pool. If either `autoscaling_min_size` or `autoscaling_max_size` are null, autoscaling is disabled"
  default     = null
}

variable "autoscaling_max_size" {
  type        = number
  description = "The maximum number of nodes in the node pool. If either `autoscaling_min_size` or `autoscaling_max_size` are null, autoscaling is disabled"
  default     = null
}

variable "auto_repair_nodes" {
  type        = bool
  description = "Whether nodes in this node pool will automatically be repaired"
  default     = true
}

variable "auto_upgrade_nodes" {
  type        = bool
  description = "Whether nodes in this node pool will automatically be upgraded"
  default     = true
}

variable "service_account" {
  type        = string
  description = "The service account to be used by the node VMs in this node pool"
  default     = null
}

variable "oauth_scope_storage_read_only" {
  type        = bool
  description = "Gives the cluster access to read private images from GCR and read all GCS content"
  default     = false
}

variable "oauth_scope_logging_write" {
  type        = bool
  description = "Gives the cluster write access to logging. Needed if the 'logging_service' points to Google"
  default     = false
}

variable "oauth_scope_monitoring" {
  type        = bool
  description = "Gives the cluster monitoring access. Needed if the 'monitoring_service' points to Google"
  default     = false
}

variable "oauth_scope_gcloud" {
  type        = bool
  description = "Gives the cluster full access. Following best practices https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances by adding full scope and manage access by IAM permissions"
  default     = true
}

variable "image_type" {
  type        = string
  description = "The image type to use for this node. Note that changing the image type will delete and recreate all nodes in the node pool."
  default     = "COS"
}

variable "metadata" {
  type        = map(string)
  description = "Key-value pairs of metadata assigned to instances in the node pool"
  default     = {}
}

variable "environment" {
  type        = string
  description = "The environment associated with the workload this node pool will handle. This should be one of: [null, 'sandbox', 'dev', 'staging', 'integ', 'prod']"
  default     = null
}

variable "owner" {
  type        = string
  description = "The human owning this node pool."
}

variable "team" {
  type        = string
  description = "The team owning this node pool."
}

variable "custom_labels" {
  type        = map(string)
  description = "Custom labels to set on the node pool"
  default     = {}
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

variable "taints" {
  description = "A list of Kubernetes taints to apply to nodes."
  type = list(object({
    effect = string,
    key    = string,
    value  = string
  }))

  default = []
}

variable "workload_identity_enabled" {
  description = "Whether to enable Workload Identity on a node pool"
  type        = bool
  default     = false
}
