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
resource "tls_private_key" "k8s_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "ibm_is_ssh_key" "k8s_ssh_key" {
  name           = "k8s-sshkey"
  public_key     = tls_private_key.k8s_key.public_key_openssh
  resource_group = data.ibm_resource_group.resource_group.id
}

resource "local_file" "private_key" {
  content         = tls_private_key.k8s_key.private_key_openssh
  filename        = "${path.module}/.ssh/id_rsa"
  file_permission = "0600"
}

resource "local_file" "public_key" {
  content  = tls_private_key.k8s_key.public_key_openssh
  filename = "${path.module}/.ssh/id_rsa.pub"
}