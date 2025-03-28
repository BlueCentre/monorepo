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


variable "cert_manager_enabled" {
  type    = bool
  default = false
}

variable "external_secrets_enabled" {
  type    = bool
  default = false
}

variable "external_dns_enabled" {
  type    = bool
  default = false
}

variable "opentelemetry_enabled" {
  type    = bool
  default = false
}

variable "datadog_enabled" {
  type    = bool
  default = false
}

variable "telepresence_enabled" {
  type    = bool
  default = false
}

variable "istio_enabled" {
  type    = bool
  default = false
}

variable "argocd_enabled" {
  type    = bool
  default = false
}

variable "cnpg_enabled" {
  type    = bool
  default = true
}


variable "workspace_bootstrapped" {
  description = "Value is true if the workspace has been bootstrapped"
  type        = bool
  default     = true
}

variable "teardown" {
  description = "Set to true to destroy all resources"
  type        = bool
  default     = false
}


variable "kubernetes_context" {
  description = "Set to kubernetes context"
  type        = string
  default     = "colima"
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  default     = "REPLACE_WITH_CLOUDFLARE_API_TOKEN"
}

variable "datadog_api_key" {
  description = "Datadog API key"
  type        = string
  default     = "REPLACE_WITH_DATADOG_API_KEY"
}

variable "redis_enabled" {
  description = "Enable Redis for Istio rate limiting"
  type        = bool
  default     = false
}

variable "redis_password" {
  description = "Password for Redis authentication"
  type        = string
  default     = "redis-password"
  sensitive   = true
}

variable "mongodb_enabled" {
  description = "Enable MongoDB for application usage"
  type        = bool
  default     = false
}

variable "mongodb_password" {
  description = "Password for MongoDB authentication"
  type        = string
  default     = "mongodb-password"
  sensitive   = true
}
