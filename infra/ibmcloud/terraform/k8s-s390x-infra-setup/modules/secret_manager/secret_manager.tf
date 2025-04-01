/*
Copyright 2025 The Kubernetes Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
locals {
  secrets_manager_region     = "eu-de"
  secrets_manager_name       = "k8s-s390x-secrets-manager"
  key                        = var.apikey
  z_service_cred_secret_name = "k8s-s390x-sm-service-credentials-secret"
}

resource "ibm_resource_instance" "secrets_manager" {
  name              = local.secrets_manager_name
  resource_group_id = var.resource_group_id
  service           = "secrets-manager"
  plan              = "standard"
  location          = local.secrets_manager_region

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
  instance_id = ibm_resource_instance.secrets_manager.guid
  region      = local.secrets_manager_region
  labels      = ["zvsi-ssh-private-key"]
  payload     = tls_private_key.private_key.private_key_openssh
}

resource "ibm_sm_arbitrary_secret" "z_ssh_public_key" {
  name        = "zvsi-ssh-public-key"
  instance_id = ibm_resource_instance.secrets_manager.guid
  region      = local.secrets_manager_region
  labels      = ["zvsi-ssh-public-key"]
  payload     = tls_private_key.private_key.public_key_openssh
}

resource "ibm_sm_arbitrary_secret" "ibm-cloud-credentials" {
  name        = "ibm-cloud-credentials"
  instance_id = ibm_resource_instance.secrets_manager.guid
  region      = local.secrets_manager_region
  labels      = ["ibm-cloud-credentials"]
  payload     = local.key
}

resource "ibm_sm_arbitrary_secret" "ibmcloud-janitor-secret" {
  name        = "ibmcloud-janitor-secret"
  instance_id = ibm_resource_instance.secrets_manager.guid
  region      = local.secrets_manager_region
  labels      = ["ibmcloud-janitor-secret"]
  payload     = local.key
}
