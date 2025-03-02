# output "env_folder" {
#   description = "Environment folder created under parent."
#   value       = module.env.env_folder
# }

output "env_secrets_project_id" {
  description = "Project for environment related secrets."
  value       = module.env.env_secrets_project_id
}

# output "env_kms_project_id" {
#   description = "Project for environment Cloud Key Management Service (KMS)."
#   value       = module.env.env_kms_project_id
# }
