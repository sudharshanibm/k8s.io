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
output "bastion_public_ips" {
  description = "Public IP addresses of bastion hosts"
  value = {
    for cluster, config in local.clusters : cluster => ibm_is_floating_ip.bastion_floating_ips[cluster].address
  }
}

output "load_balancer_public_ips" {
  description = "Public IP addresses of load balancers"
  value = {
    for cluster, config in local.clusters : cluster => ibm_is_lb.control_plane_lbs[cluster].public_ips[0]
  }
}

output "ssh_commands" {
  description = "SSH commands to access bastion hosts"
  value = {
    for cluster, config in local.clusters : cluster => "ssh -i ${var.ssh_private_key_path} root@${ibm_is_floating_ip.bastion_floating_ips[cluster].address}"
  }
}

output "kubeconfig_commands" {
  description = "Commands to retrieve kubeconfig"
  value = {
    for cluster, config in local.clusters : cluster => "ssh -i ${var.ssh_private_key_path} -J root@${ibm_is_floating_ip.bastion_floating_ips[cluster].address} root@${ibm_is_instance.master_nodes[cluster].primary_network_interface[0].primary_ipv4_address} 'sudo cat /etc/kubernetes/admin.conf' > kubeconfig-${cluster}"
  }
}

output "bastion_ips" {
  value = {
    for k, v in ibm_is_floating_ip.bastion_floating_ips : k => v.address
  }
}

output "master_node_ips" {
  value = {
    for k, v in ibm_is_instance.master_nodes : k => v.primary_network_interface[0].primary_ipv4_address
  }
}

output "security_group_ids" {
  value = {
    for k, v in data.ibm_is_vpc.vpcs : k => v.default_security_group
  }
}

output "master_nodes_status" {
  value = {
    for k, v in ibm_is_instance.master_nodes : k => {
      id     = v.id
      status = v.status
      ip     = v.primary_network_interface[0].primary_ipv4_address
    }
  }
}

output "bastion_connectivity" {
  value = {
    for k, v in ibm_is_instance.bastions : k => {
      bastion_ip = ibm_is_floating_ip.bastion_floating_ips[k].address
      target_ip  = ibm_is_instance.master_nodes[k].primary_network_interface[0].primary_ipv4_address
    }
  }
}

output "master_node_network_interfaces" {
  value = {
    for k, v in ibm_is_instance.master_nodes : k => {
      id   = v.primary_network_interface[0].id
      ip   = v.primary_network_interface[0].primary_ipv4_address
      name = v.name
    }
  }
}

output "instance_nic_ids" {
  value = {
    for k, v in ibm_is_instance.master_nodes :
    k => v.primary_network_interface[0].id
  }
}

output "lb_status" {
  value = {
    for k, v in ibm_is_lb.control_plane_lbs :
    k => {
      id               = v.id,
      status           = v.status,
      operating_status = v.operating_status
    }
  }
}