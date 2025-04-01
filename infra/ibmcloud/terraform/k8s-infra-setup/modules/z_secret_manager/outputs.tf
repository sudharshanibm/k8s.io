output "k8s_secrets_manager_id" {
  value = ibm_resource_instance.z_secrets_manager.guid
}

output "k8s_z_ssh_public_key" {
  value = tls_private_key.private_key.public_key_openssh
}
