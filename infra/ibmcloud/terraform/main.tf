module "resource_group" {
  source = "./modules/resource_group"
  prefix = var.prefix
}

module "iam_custom_role" {
  source = "./modules/iam/custom_role"
}

module "service_ids" {
  depends_on        = [module.iam_custom_role]
  source            = "./modules/iam/service_ids"
  prefix            = var.prefix
  resource_group_id = module.resource_group.k8s_resource_group_id
}

module "iam_access_groups" {
  depends_on        = [module.iam_custom_role]
  source            = "./modules/iam/access_groups"
  prefix            = var.prefix
  resource_group_id = module.resource_group.k8s_resource_group_id
}

module "ibm_cos" {
  source            = "./modules/cos"
  prefix            = var.prefix
  resource_group_id = module.resource_group.k8s_resource_group_id
}

module "secrets_manager" {
  source            = "./modules/secrets_manager"
  prefix            = var.prefix
  resource_group_id = module.resource_group.k8s_resource_group_id
  access_group_id   = module.iam_access_groups.k8s_access_group_id
  cos_instance_guid = module.ibm_cos.k8s_cos_instance_guid
  cos_instance_id   = module.ibm_cos.k8s_cos_instance_id
  apikey            = local.key
}
