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
  control_plane_nodes = {
    for idx in range(1, var.control_plane_node_count + 1) :
    "${idx}" => {
      profile = var.control_plane_node_profile
      boot_volume = {
        size = var.control_plane_boot_volume_size
      }
    }
  }

  compute_nodes = {
    for idx in range(1, var.compute_node_count + 1) :
    "${idx}" => {
      profile = var.compute_node_profile
      boot_volume = {
        size = var.compute_boot_volume_size
      }
    }
  }
}
resource "ibm_is_ssh_key" "k8s_ssh_key" {
  name           = "k8s-s390x-ssh-key"
  public_key     = local.bootstrap_ssh_public_key
  resource_group = data.ibm_resource_group.resource_group.id

  lifecycle {
    precondition {
      condition     = local.bootstrap_ssh_key_is_valid
      error_message = "The Secrets Manager public key must be a single valid authorized_keys line before Terraform can provision access."
    }
  }
}

resource "ibm_is_instance" "control_plane" {
  for_each = local.control_plane_nodes

  name           = "control-plane-s390x-${each.key}"
  vpc            = data.ibm_is_vpc.vpc.id
  zone           = var.zone
  profile        = each.value.profile
  image          = data.ibm_is_image.os_image.id
  keys           = [ibm_is_ssh_key.k8s_ssh_key.id]
  resource_group = data.ibm_resource_group.resource_group.id

  primary_network_interface {
    subnet          = data.ibm_is_subnet.subnet.id
    security_groups = [data.ibm_is_security_group.control_plane_sg.id]
  }

  boot_volume {
    name = "boot-vol-cp-s390x-${each.key}"
    size = each.value.boot_volume.size
  }

  lifecycle {
    precondition {
      condition     = local.bootstrap_ssh_key_is_valid
      error_message = "The Secrets Manager public key must be a single valid authorized_keys line before Terraform can provision access."
    }
  }

  user_data = <<-EOF
              #cloud-config
              package_update: true
              package_upgrade: true
              disable_root: false
              ssh_pwauth: false
              
              # Preserve the distro default account and add the automation user.
              users:
                - default
                - name: ${local.bootstrap_admin_user}
                  gecos: Kubernetes Administrator
                  groups: sudo
                  lock_passwd: true
                  shell: /bin/bash
                  ssh_authorized_keys:
                    - ${jsonencode(local.bootstrap_ssh_public_key)}
              
              write_files:
                - path: /etc/ssh/sshd_config.d/99-security.conf
                  content: |
                    PermitRootLogin prohibit-password
                    PasswordAuthentication no
                    PubkeyAuthentication yes
                - path: /etc/sudoers.d/k8s-admin
                  content: |
                    # Passwordless sudo for k8s-admin user
                    # Required for Ansible automation - Ansible modules use Python internally
                    # Security: Access is still restricted by SSH key authentication
                    k8s-admin ALL=(ALL) NOPASSWD: ALL
                  permissions: '0440'
              
              runcmd:
                - [systemctl, restart, sshd]
                - [hostnamectl, set-hostname, "control-plane-s390x-${each.key}.s390x-vpc.cloud.ibm.com"]
              EOF
}

resource "ibm_is_instance" "compute" {
  for_each = local.compute_nodes

  name           = "worker-s390x-${each.key}"
  vpc            = data.ibm_is_vpc.vpc.id
  zone           = var.zone
  profile        = each.value.profile
  image          = data.ibm_is_image.os_image.id
  keys           = [ibm_is_ssh_key.k8s_ssh_key.id]
  resource_group = data.ibm_resource_group.resource_group.id

  primary_network_interface {
    subnet          = data.ibm_is_subnet.subnet.id
    security_groups = [data.ibm_is_security_group.worker_sg.id]
  }

  boot_volume {
    name = "boot-vol-worker-s390x-${each.key}"
    size = each.value.boot_volume.size
  }

  lifecycle {
    precondition {
      condition     = local.bootstrap_ssh_key_is_valid
      error_message = "The Secrets Manager public key must be a single valid authorized_keys line before Terraform can provision access."
    }
  }

  user_data = <<-EOF
              #cloud-config
              package_update: true
              package_upgrade: true
              disable_root: false
              ssh_pwauth: false
              
              # Preserve the distro default account and add the automation user.
              users:
                - default
                - name: ${local.bootstrap_admin_user}
                  gecos: Kubernetes Administrator
                  groups: sudo
                  lock_passwd: true
                  shell: /bin/bash
                  ssh_authorized_keys:
                    - ${jsonencode(local.bootstrap_ssh_public_key)}
              
              write_files:
                - path: /etc/ssh/sshd_config.d/99-security.conf
                  content: |
                    PermitRootLogin prohibit-password
                    PasswordAuthentication no
                    PubkeyAuthentication yes
                - path: /etc/sudoers.d/k8s-admin
                  content: |
                    # Passwordless sudo for k8s-admin user
                    # Required for Ansible automation - Ansible modules use Python internally
                    # Security: Access is still restricted by SSH key authentication
                    k8s-admin ALL=(ALL) NOPASSWD: ALL
                  permissions: '0440'
              
              runcmd:
                - [systemctl, restart, sshd]
                - [hostnamectl, set-hostname, "worker-s390x-${each.key}.s390x-vpc.cloud.ibm.com"]
              EOF
}
