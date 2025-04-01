locals {
  z_secrets_manager_region   = "eu-de"
  z_secrets_manager_name     = "${var.prefix_z}-secrets-manager"
  key                        = var.apikey
  z_service_cred_secret_name = "${var.prefix_z}-sm-service-credentials-secret"
}

resource "ibm_resource_instance" "z_secrets_manager" {
  name              = local.z_secrets_manager_name
  resource_group_id = var.resource_group_id
  service           = "secrets-manager"
  plan              = "standard"
  location          = local.z_secrets_manager_region

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

# RSA key of size 4096 bits
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "ibm_sm_arbitrary_secret" "z_ssh_private_key" {
  name        = "zvsi-ssh-private-key"
  instance_id = ibm_resource_instance.z_secrets_manager.guid
  region      = local.z_secrets_manager_region
  labels      = ["zvsi-ssh-private-key"]
  payload     = tls_private_key.private_key.private_key_openssh
}

resource "ibm_sm_arbitrary_secret" "z_ssh_public_key" {
  name        = "zvsi-ssh-public-key"
  instance_id = ibm_resource_instance.z_secrets_manager.guid
  region      = local.z_secrets_manager_region
  labels      = ["zvsi-ssh-public-key"]
  payload     = tls_private_key.private_key.public_key_openssh
}

resource "ibm_sm_arbitrary_secret" "ibm-cloud-credentials" {
  name        = "ibm-cloud-credentials"
  instance_id = ibm_resource_instance.z_secrets_manager.guid
  region      = local.z_secrets_manager_region
  labels      = ["ibm-cloud-credentials"]
  payload     = local.key
}

resource "ibm_sm_arbitrary_secret" "ibmcloud-janitor-secret" {
  name        = "ibmcloud-janitor-secret"
  instance_id = ibm_resource_instance.z_secrets_manager.guid
  region      = local.z_secrets_manager_region
  labels      = ["ibmcloud-janitor-secret"]
  payload     = local.key
}
