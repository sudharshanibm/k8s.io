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
  tcp_ports = [22, 6443, 80, 443]
  vpc_configs = {
    conformance = { zone = "eu-de-1", resource_group = var.resource_group_conformance },
    e2e         = { zone = "eu-de-2", resource_group = var.resource_group_e2e },
    unit        = { zone = "eu-de-3", resource_group = var.resource_group_unit }
  }
}

resource "ibm_is_vpc" "vpcs" {
  for_each       = local.vpc_configs
  name           = "k8s-vpc-${each.key}"
  resource_group = each.value.resource_group
  tags           = ["k8s", "s390x"]
}

resource "ibm_is_subnet" "subnets" {
  for_each                 = local.vpc_configs
  name                     = "k8s-subnet-${each.key}"
  vpc                      = ibm_is_vpc.vpcs[each.key].id
  resource_group           = each.value.resource_group
  total_ipv4_address_count = 256
  zone                     = each.value.zone
  tags                     = ["k8s", "s390x"]
}

resource "ibm_is_security_group" "bastion_sg" {
  for_each       = local.vpc_configs
  name           = "k8s-vpc-${each.key}-bastion-sg"
  vpc            = ibm_is_vpc.vpcs[each.key].id
  resource_group = each.value.resource_group
}

resource "ibm_is_security_group" "master_sg" {
  for_each       = local.vpc_configs
  name           = "k8s-vpc-${each.key}-master-sg"
  vpc            = ibm_is_vpc.vpcs[each.key].id
  resource_group = each.value.resource_group
}

resource "ibm_is_security_group" "worker_sg" {
  for_each       = local.vpc_configs
  name           = "k8s-vpc-${each.key}-worker-sg"
  vpc            = ibm_is_vpc.vpcs[each.key].id
  resource_group = each.value.resource_group
}

# Bastion Rules
resource "ibm_is_security_group_rule" "bastion_inbound_ssh" {
  for_each  = local.vpc_configs
  group     = ibm_is_security_group.bastion_sg[each.key].id
  direction = "inbound"
  remote    = var.allowed_ssh_cidr
  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_security_group_rule" "bastion_inbound_icmp" {
  for_each  = local.vpc_configs
  group     = ibm_is_security_group.bastion_sg[each.key].id
  direction = "inbound"
  remote    = var.allowed_ssh_cidr
  icmp {
    type = 8
  }
}

resource "ibm_is_security_group_rule" "bastion_outbound" {
  for_each  = local.vpc_configs
  group     = ibm_is_security_group.bastion_sg[each.key].id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

# Master Rules
resource "ibm_is_security_group_rule" "master_inbound" {
  for_each  = local.vpc_configs
  group     = ibm_is_security_group.master_sg[each.key].id
  direction = "inbound"
  remote    = ibm_is_security_group.bastion_sg[each.key].id
  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_security_group_rule" "master_k8s_api" {
  for_each  = local.vpc_configs
  group     = ibm_is_security_group.master_sg[each.key].id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 6443
    port_max = 6443
  }
}

# Worker Rules
resource "ibm_is_security_group_rule" "worker_inbound" {
  for_each  = local.vpc_configs
  group     = ibm_is_security_group.worker_sg[each.key].id
  direction = "inbound"
  remote    = ibm_is_security_group.bastion_sg[each.key].id
  tcp {
    port_min = 22
    port_max = 22
  }
}

# Internal Communication
resource "ibm_is_security_group_rule" "internal_communication" {
  for_each  = local.vpc_configs
  group     = ibm_is_security_group.master_sg[each.key].id
  direction = "inbound"
  remote    = ibm_is_security_group.worker_sg[each.key].id
}