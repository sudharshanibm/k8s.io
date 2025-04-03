output "control_plane_ips" {
  value = {
    for k, inst in ibm_is_instance.control_plane_nodes :
    k => inst.primary_network_interface[0].primary_ipv4_address
  }
}

output "bastion_public_ips" {
  value = {
    for k, inst in ibm_is_instance.bastions :
    k => inst.primary_network_interface[0].primary_ipv4_address
  }
}

output "bastion_internal_ips" {
  value = {
    for k, inst in ibm_is_instance.bastions :
    k => inst.primary_network_interface[0].primary_ipv4_address
  }
}

output "bastion_private_cidrs" {
  value = {
    for k, subnet in data.ibm_is_subnet.subnets :
    k => subnet.ipv4_cidr_block
  }
}

output "bastion_private_gateways" {
  value = {
    for k, subnet in data.ibm_is_subnet.subnets :
    k => "${cidrhost(subnet.ipv4_cidr_block, 1)}"
  }
}


output "compute_ips" {
  value = {
    for k, inst in ibm_is_instance.control_plane_nodes :
    k => inst.primary_network_interface[0].primary_ipv4_address
  }
}

output "loadbalancer_hostnames" {
  value = {
    for k, lb in ibm_is_lb.control_plane_lbs :
    k => lb.hostname
  }
}
