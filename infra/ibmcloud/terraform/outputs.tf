output "k8s_resource_group_id" {
  value = module.resource_group.k8s_resource_group_id
}

output "k8s_secrets_manager_id" {
  value = module.secrets_manager.k8s_secrets_manager_id
}

output "k8s_iam_credentials_secret_name" {
  value = module.secrets_manager.k8s_iam_credentials_secret
}

output "k8s_service_credentials_secret_name" {
  value = module.secrets_manager.k8s_service_credentials_secret
}

output "k8s_powervs_ssh_private_key_id" {
  value = module.secrets_manager.k8s_powervs_ssh_private_key_id
}

output "k8s_powervs_ssh_public_key_id" {
  value = module.secrets_manager.k8s_powervs_ssh_public_key_id
}
