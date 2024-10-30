output "k8s_secrets_manager_id" {
  value = ibm_resource_instance.secrets_manager.guid
}

output "k8s_iam_credentials_secret" {
  value = ibm_sm_iam_credentials_secret.sm_iam_credentials_secret.name
}

output "k8s_service_credentials_secret" {
  value = ibm_sm_service_credentials_secret.sm_service_credentials_secret.name
}

output "k8s_powervs_ssh_private_key_id" {
  value = ibm_sm_arbitrary_secret.ssh_private_key.secret_id
}

output "k8s_powervs_ssh_public_key_id" {
  value = ibm_sm_arbitrary_secret.ssh_public_key.secret_id
}

output "k8s_powervs_ssh_public_key" {
  value = tls_private_key.private_key.public_key_openssh
}
