output "base_shared_vpc_project_id" {
  description = "Project id for base shared VPC network."
  value       = "prj-lab-james-nguyen"
  # value       = module.base_shared_vpc_host_project.project_id
}

output "base_shared_vpc_project_number" {
  description = "Project number for base shared VPC network."
  value       = "681831149067"
  # value       = module.base_shared_vpc_host_project.project_number
}

output "restricted_shared_vpc_project_id" {
  description = "Project id for restricted shared VPC network."
  value       = "prj-lab-james-nguyen"
  # value       = module.restricted_shared_vpc_host_project.project_id
}

output "restricted_shared_vpc_project_number" {
  description = "Project number for restricted shared VPC."
  value       = "681831149067"
  # value       = module.restricted_shared_vpc_host_project.project_number
}
