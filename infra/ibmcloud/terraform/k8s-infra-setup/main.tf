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

module "resource_group" {
  count  = var.target_architecture == "ppc64le" ? 1 : 0
  source = "./modules/resource_group"
}

module "secrets_manager" {
  count             = var.target_architecture == "ppc64le" ? 1 : 0
  source            = "./modules/secrets_manager"
  resource_group_id = module.resource_group[count.index].k8s_rg_id
}

module "vpc" {
  count = var.target_architecture == "ppc64le" ? 1 : 0
  providers = {
    ibm = ibm.vpc
  }
  source            = "./modules/vpc"
  resource_group_id = module.resource_group[count.index].k8s_rg_id
}

module "transit_gateway" {
  count      = var.target_architecture == "ppc64le" ? 1 : 0
  depends_on = [module.vpc]
  providers = {
    ibm = ibm.vpc
  }
  source            = "./modules/transit_gateway"
  resource_group_id = module.resource_group[count.index].k8s_rg_id
  vpc_crn           = module.vpc[count.index].crn
  powervs_crn       = ibm_pi_workspace.build_cluster[count.index].crn
}

module "z_resource_group" {
  count    = var.target_architecture == "s390x" ? 1 : 0
  source   = "./modules/z_resource_group"
  prefix_z = var.prefix_z
}
module "z_secrets_manager" {
  count             = var.target_architecture == "s390x" ? 1 : 0
  source            = "./modules/z_secret_manager"
  prefix_z          = var.prefix_z
  resource_group_id = module.z_resource_group[count.index].conformance_resource_group_id
  apikey            = local.key
}
module "vpcs" {
  providers = {
    ibm = ibm.vpcs
  }
  source                     = "./modules/z_vpc"
  resource_group_conformance = module.z_resource_group[count.index].conformance_resource_group_id
  resource_group_e2e         = module.z_resource_group[count.index].e2e_resource_group_id
  resource_group_unit        = module.z_resource_group[count.index].unit_resource_group_id
}

