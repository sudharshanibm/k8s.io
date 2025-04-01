locals {
  tcp_ports = [6443]

  vpc_configs = [
    { name = "k8s-vpc-conformance", zone = "eu-de-1", resource_group = var.resource_group_conformance },
    { name = "k8s-vpc-e2e", zone = "eu-de-2", resource_group = var.resource_group_e2e },
    { name = "k8s-vpc-unit", zone = "eu-de-3", resource_group = var.resource_group_unit }
  ]
}

# Create VPCs dynamically
resource "ibm_is_vpc" "vpcs" {
  for_each       = { for v in local.vpc_configs : v.name => v }
  name           = each.value.name
  resource_group = each.value.resource_group
}

# Create Subnets dynamically
resource "ibm_is_subnet" "subnets" {
  for_each                 = { for v in local.vpc_configs : v.name => v }
  name                     = replace(each.key, "vpc", "subnet")
  vpc                      = ibm_is_vpc.vpcs[each.key].id
  resource_group           = each.value.resource_group
  total_ipv4_address_count = 256
  zone                     = each.value.zone
}

# Create Security Group Rules dynamically
resource "ibm_is_security_group_rule" "inbound_ports" {
  for_each  = { for v in local.vpc_configs : v.name => v }
  group     = ibm_is_vpc.vpcs[each.key].default_security_group
  direction = "inbound"

  dynamic "tcp" {
    for_each = local.tcp_ports
    content {
      port_min = tcp.value
      port_max = tcp.value
    }
  }
}
