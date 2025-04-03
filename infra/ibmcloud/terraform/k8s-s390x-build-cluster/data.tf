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
data "ibm_resource_group" "resource_groups" {
  for_each = local.clusters
  name     = each.value.resource_group
}

data "ibm_is_vpc" "vpcs" {
  for_each = local.clusters
  name     = each.value.vpc
}

data "ibm_is_subnet" "subnets" {
  for_each = local.clusters
  name     = each.value.subnet
}

data "ibm_is_security_groups" "sgs" {
  for_each = local.clusters
  vpc_id   = data.ibm_is_vpc.vpcs[each.key].id
}

data "ibm_is_security_group" "bastion_sg" {
  for_each = local.clusters
  name     = "k8s-vpc-${each.key}-bastion-sg"
  vpc      = data.ibm_is_vpc.vpcs[each.key].id
}

data "ibm_is_security_group" "master_sg" {
  for_each = local.clusters
  name     = "k8s-vpc-${each.key}-master-sg"
  vpc      = data.ibm_is_vpc.vpcs[each.key].id
}

data "ibm_is_security_group" "worker_sg" {
  for_each = local.clusters
  name     = "k8s-vpc-${each.key}-worker-sg"
  vpc      = data.ibm_is_vpc.vpcs[each.key].id
}