variable "project_id" {
  default = ""
}

variable "project_region" {
  default = ""
}

variable "project_primary_region" {
  default = ""
}

variable "project_secondary_region" {
  default = ""
}

variable "project_zone" {
  default = ""
}

variable "project_location" {
  default = ""
}



variable "environment" {
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
  default     = true
}

variable "artifact_registry_name" {
  default = ""
}



# variable "compute_additional_metadata" {
#   type        = map(string)
#   description = "Additional metadata to attach to the instance"
#   default     = {}
# }

# variable "compute_instance_name" {
#   default = "coder-host"
# }


variable "harness_enabled" {
  description = "Enable harness integration"
  type        = bool
  default     = false  
}
