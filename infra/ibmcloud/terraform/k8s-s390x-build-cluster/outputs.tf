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
output "bastion_private_ip" {
  description = "Private IP address(es) of the bastion host(s)"
  value       = ibm_is_instance.bastion[*].primary_network_interface[0].primary_ipv4_address
}

output "bastion_private_cidr" {
  description = "CIDR block of the subnet where bastion is deployed"
  value       = data.ibm_is_subnet.subnet.ipv4_cidr_block
}

output "bastion_private_gateway" {
  description = "Calculated gateway IP (first IP in subnet)"
  value       = cidrhost(data.ibm_is_subnet.subnet.ipv4_cidr_block, 1)
}

output "bastion_public_ip" {
  description = "Public Floating IP(s) assigned to the bastion"
  value       = ibm_is_floating_ip.bastion_fip[*].address
}

output "master_node_ips" {
  description = "Private IP addresses of control plane nodes"
  value       = ibm_is_instance.control_plane[*].primary_network_interface[0].primary_ipv4_address
}

output "worker_node_ips" {
  description = "Private IP addresses of worker nodes"
  value       = ibm_is_instance.compute[*].primary_network_interface[0].primary_ipv4_address
}

output "loadbalancer_hostname" {
  description = "Hostname of the Kubernetes API load balancer"
  value       = ibm_is_lb.load_balancer.hostname
}