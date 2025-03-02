variable "project_id" {
  type    = string
  default = ""
}

variable "project_region" {
  type    = string
  default = ""
}

variable "project_primary_region" {
  type    = string
  default = ""
}

variable "project_secondary_region" {
  type    = string
  default = ""
}

variable "project_zone" {
  type    = string
  default = ""
}

variable "project_location" {
  type    = string
  default = ""
}


variable "environment" {
  type    = string
  default = ""
}

variable "stack" {
  type    = string
  default = ""
}

variable "tenant" {
  type    = string
  default = ""
}

variable "region" {
  type    = string
  default = ""
}


variable "remote_state_bucket" {
  type    = string
  default = ""
}


variable "project_prefix" {
  description = "Name prefix to use for projects created. Should be the same in all steps. Max size is 3 characters."
  type        = string
  default     = "prj"
}

variable "folder_prefix" {
  description = "Name prefix to use for folders created. Should be the same in all steps."
  type        = string
  default     = "fldr"
}

variable "bucket_prefix" {
  description = "Name prefix to use for state bucket created."
  type        = string
  default     = "bkt"
}

variable "bucket_force_destroy" {
  description = "When deleting a bucket, this boolean option will delete all contained objects. If false, Terraform will fail to delete buckets which contain objects."
  type        = bool
  default     = false
}


variable "artifact_registry_name" {
  description = "Name of the Artifact Registry."
  type        = string
  default     = ""
}


variable "network_name" {
  type    = string
  default = ""
}

variable "subnet_name" {
  type    = string
  default = ""
}

variable "ip_range_pod" {
  type    = string
  default = ""
}

variable "ip_range_svc" {
  type    = string
  default = ""
}

variable "master_ipv4_cidr_block" {
  type    = string
  default = "10.250.0.0/28"
}

variable "network_tags" {
  type    = list(string)
  default = ["allow-google-apis", "egress-inet"]
}


variable "instance_number" {
  type    = number
  default = 0
}

variable "min_pool_count" {
  type    = number
  default = 0
}

variable "max_pool_count" {
  type    = number
  default = 3
}

variable "node_pool_instance_type" {
  type    = string
  default = ""
}

variable "release_channel" {
  type    = string
  default = "REGULAR"
}


variable "teardown" {
  description = "Set to true to destroy all resources"
  type        = bool
  default     = false
}
