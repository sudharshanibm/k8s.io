output "k8s_resource_group_id" {
  value = var.resource_group_id
}

output "k8s_secrets_manager_id" {
  value = length(module.secrets_manager) > 0 ? module.secrets_manager[0].k8s_secrets_manager_id : null
}

output "k8s_iam_credentials_secret_name" {
  value = length(module.secrets_manager) > 0 ? module.secrets_manager[0].k8s_iam_credentials_secret : null
}

output "k8s_service_credentials_secret_name" {
  value = length(module.secrets_manager) > 0 ? module.secrets_manager[0].k8s_service_credentials_secret : null
}

output "k8s_powervs_ssh_private_key_id" {
  value = length(module.secrets_manager) > 0 ? module.secrets_manager[0].k8s_powervs_ssh_private_key_id : null
}

output "k8s_powervs_ssh_public_key_id" {
  value = length(module.secrets_manager) > 0 ? module.secrets_manager[0].k8s_powervs_ssh_public_key_id : null
}

output "vpc_id" { value = local.vpc_id }
output "ssh_key_id" { value = data.ibm_is_ssh_key.ssh_key.id }
output "subnet_id" { value = local.subnet_id }
output "security_group_id" { value = local.security_group_id }
output "region" { value = var.vpc_region }
output "zone" { value = var.vpc_zone }
output "resource_group_id" { value = data.ibm_resource_group.default_group.id }
output "masters" {
  value = module.master[*].public_ip
  description = "k8s master node IP addresses"
}

output "workers" {
  value = module.workers[*].public_ip
  description = "k8s worker node IP addresses"
}

output "masters_private" {
  value = module.master[*].private_ip
  description = "k8s master nodes private IP addresses"
}

output "workers_private" {
  value = module.workers[*].private_ip
  description = "k8s worker nodes private IP addresses"
}