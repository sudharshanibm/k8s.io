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
resource "ibm_is_vpc" "vpc" {
  name           = "k8s-s390x-vpc"
  resource_group = var.resource_group_id
}

resource "ibm_is_subnet" "subnet" {
  name                     = "k8s-s390x-subnet"
  vpc                      = ibm_is_vpc.vpc.id
  resource_group           = var.resource_group_id
  total_ipv4_address_count = 256
  zone                     = "eu-de-1"
}

resource "ibm_is_security_group" "bastion_sg" {
  name           = "k8s-vpc-s390x-bastion-sg"
  vpc            = ibm_is_vpc.vpc.id
  resource_group = var.resource_group_id
}

resource "ibm_is_security_group" "master_sg" {
  name           = "k8s-vpc-s390x-master-sg"
  vpc            = ibm_is_vpc.vpc.id
  resource_group = var.resource_group_id
}

resource "ibm_is_security_group" "worker_sg" {
  name           = "k8s-vpc-s390x-worker-sg"
  vpc            = ibm_is_vpc.vpc.id
  resource_group = var.resource_group_id
}

resource "ibm_is_security_group_rule" "bastion_inbound_ssh" {
  group     = ibm_is_security_group.bastion_sg.id
  direction = "inbound"
  tcp {
    port_min = 22
    port_max = 22
  }
}
resource "ibm_is_security_group_rule" "master_k8s_api" {
  group     = ibm_is_security_group.master_sg.id
  direction = "inbound"
  tcp {
    port_min = 6443
    port_max = 6443
  }
  remote = ibm_is_subnet.subnet.ipv4_cidr_block
}