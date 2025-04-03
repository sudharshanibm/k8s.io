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
resource "ibm_is_ssh_key" "ssh_key" {
  for_each       = local.clusters
  name           = "bastion-ssh-key-${each.key}"
  public_key     = file(var.ssh_public_key_path)
  resource_group = data.ibm_resource_group.resource_groups[each.key].id
}

resource "ibm_is_instance" "bastions" {
  for_each       = local.clusters
  name           = "bastion-${each.key}"
  image          = "r010-1476c687-824d-4b10-b604-7538defb3c73"
  profile        = "bz2-2x8"
  vpc            = data.ibm_is_vpc.vpcs[each.key].id
  zone           = each.value.zone
  resource_group = data.ibm_resource_group.resource_groups[each.key].id
  keys           = [ibm_is_ssh_key.ssh_key[each.key].id]

  primary_network_interface {
    subnet          = data.ibm_is_subnet.subnets[each.key].id
    security_groups = [data.ibm_is_security_group.bastion_sg[each.key].id]
  }

  user_data = <<-EOF
    #!/bin/bash
    # Configure SSH forwarding
    echo 'GatewayPorts yes' >> /etc/ssh/sshd_config
    echo 'AllowTcpForwarding yes' >> /etc/ssh/sshd_config
    echo 'PermitRootLogin prohibit-password' >> /etc/ssh/sshd_config
    
    # Install and configure SSH keys
    mkdir -p /root/.ssh
    echo '${file(var.ssh_public_key_path)}' > /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    
    systemctl restart sshd
  EOF
}

resource "ibm_is_floating_ip" "bastion_floating_ips" {
  for_each       = local.clusters
  name           = "bastion-fip-${each.key}"
  target         = ibm_is_instance.bastions[each.key].primary_network_interface[0].id
  resource_group = data.ibm_resource_group.resource_groups[each.key].id
}

resource "ibm_is_security_group_rule" "bastion_to_master" {
  for_each  = local.clusters
  group     = data.ibm_is_security_group.master_sg[each.key].id
  direction = "inbound"
  remote    = data.ibm_is_security_group.bastion_sg[each.key].id
  tcp {
    port_min = 22
    port_max = 22
  }
}