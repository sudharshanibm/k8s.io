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
resource "ibm_is_instance" "master_nodes" {
  for_each       = local.clusters
  name           = "master-${each.key}"
  image          = "r010-1476c687-824d-4b10-b604-7538defb3c73"
  profile        = "bz2-4x16"
  vpc            = data.ibm_is_vpc.vpcs[each.key].id
  zone           = each.value.zone
  resource_group = data.ibm_resource_group.resource_groups[each.key].id
  keys           = [ibm_is_ssh_key.ssh_key[each.key].id]

  primary_network_interface {
    subnet               = data.ibm_is_subnet.subnets[each.key].id
    security_groups      = [data.ibm_is_security_group.master_sg[each.key].id]
    primary_ipv4_address = cidrhost(data.ibm_is_subnet.subnets[each.key].ipv4_cidr_block, 10)
  }

  user_data = <<-EOF
    #!/bin/bash
    # Configure SSH
    mkdir -p /root/.ssh
    echo '${file(var.ssh_public_key_path)}' > /root/.ssh/authorized_keys
    chmod 700 /root/.ssh
    chmod 600 /root/.ssh/authorized_keys
    
    # Allow SSH from bastion
    echo 'Match Address ${ibm_is_floating_ip.bastion_floating_ips[each.key].address}' >> /etc/ssh/sshd_config
    echo '    AllowTcpForwarding yes' >> /etc/ssh/sshd_config
    echo '    PermitRootLogin prohibit-password' >> /etc/ssh/sshd_config
    
    systemctl restart sshd
  EOF

  depends_on = [ibm_is_floating_ip.bastion_floating_ips]
}
resource "ibm_is_instance" "worker_nodes" {
  for_each = { for idx, cluster in flatten([
    for cluster_key, cluster in local.clusters : [
      for i in range(3) : {
        cluster_key = cluster_key
        node_index  = i
        cluster     = cluster
      }
    ]
  ]) : "${cluster.cluster_key}-${cluster.node_index}" => cluster }

  name           = "worker-${each.value.cluster_key}-node-${each.value.node_index}"
  image          = "r010-1476c687-824d-4b10-b604-7538defb3c73"
  profile        = "bz2-2x8"
  vpc            = data.ibm_is_vpc.vpcs[each.value.cluster_key].id
  zone           = each.value.cluster.zone
  resource_group = data.ibm_resource_group.resource_groups[each.value.cluster_key].id
  keys           = [ibm_is_ssh_key.ssh_key[each.value.cluster_key].id]

  primary_network_interface {
    subnet = data.ibm_is_subnet.subnets[each.value.cluster_key].id
    security_groups = [
      data.ibm_is_security_group.worker_sg[each.value.cluster_key].id
    ]
    primary_ip {
      auto_delete = true
    }
  }

  timeouts {
    create = "60m"
    delete = "60m"
  }

  depends_on = [
    ibm_is_instance.master_nodes
  ]
}