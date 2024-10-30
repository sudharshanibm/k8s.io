resource "ibm_pi_workspace" "housekeeping" {
  pi_name              = "${var.prefix}-housekeeping"
  pi_datacenter        = "us-south"
  pi_resource_group_id = module.resource_group.k8s_resource_group_id
}

resource "ibm_pi_key" "sshkey" {
  pi_key_name          = "${var.prefix}-sshkey"
  pi_ssh_key           = module.secrets_manager.k8s_powervs_ssh_public_key
  pi_cloud_instance_id = ibm_pi_workspace.housekeeping.id
}

module "powervs_workspace_dal12" {
  providers = {
    ibm = ibm.powervs_dal12
  }
  source            = "./modules//pvs_workspace"
  datacenter        = "dal12"
  pi_workspace_name = "${var.prefix}-boskos-dal12"
  resource_group_id = module.resource_group.k8s_resource_group_id
  image_name        = var.pvs_image_name
}

module "powervs_workspace_us_south" {
  providers = {
    ibm = ibm.powervs_us-south
  }
  depends_on        = [ibm_pi_workspace.housekeeping]
  source            = "./modules//pvs_workspace"
  datacenter        = "us-south"
  pi_workspace_name = "${var.prefix}-boskos-us-south"
  resource_group_id = module.resource_group.k8s_resource_group_id
  image_name        = var.pvs_image_name
}

module "powervs_workspace_wdc06" {
  providers = {
    ibm = ibm.powervs_wdc06
  }
  source            = "./modules//pvs_workspace"
  datacenter        = "wdc06"
  pi_workspace_name = "${var.prefix}-boskos-wdc06"
  resource_group_id = module.resource_group.k8s_resource_group_id
  image_name        = var.pvs_image_name
}

module "powervs_workspace_us_east" {
  providers = {
    ibm = ibm.powervs_us-east
  }
  source            = "./modules//pvs_workspace"
  datacenter        = "us-east"
  pi_workspace_name = "${var.prefix}-boskos-us-east"
  resource_group_id = module.resource_group.k8s_resource_group_id
  image_name        = var.pvs_image_name
}

module "powervs_workspace_sao01" {
  providers = {
    ibm = ibm.powervs_sao01
  }
  source            = "./modules//pvs_workspace"
  datacenter        = "sao01"
  pi_workspace_name = "${var.prefix}-boskos-sao01"
  resource_group_id = module.resource_group.k8s_resource_group_id
  image_name        = var.pvs_image_name
}

module "powervs_workspace_tor01" {
  providers = {
    ibm = ibm.powervs_tor01
  }
  source            = "./modules//pvs_workspace"
  datacenter        = "tor01"
  pi_workspace_name = "${var.prefix}-boskos-tor01"
  resource_group_id = module.resource_group.k8s_resource_group_id
  image_name        = var.pvs_image_name
}

module "powervs_workspace_mon01" {
  providers = {
    ibm = ibm.powervs_mon01
  }
  source            = "./modules//pvs_workspace"
  datacenter        = "mon01"
  pi_workspace_name = "${var.prefix}-boskos-mon01"
  resource_group_id = module.resource_group.k8s_resource_group_id
  image_name        = var.pvs_image_name
}

module "powervs_workspace_eu_de_1" {
  providers = {
    ibm = ibm.powervs_eu-de-1
  }
  source            = "./modules//pvs_workspace"
  datacenter        = "eu-de-1"
  pi_workspace_name = "${var.prefix}-boskos-eu-de-1"
  resource_group_id = module.resource_group.k8s_resource_group_id
  image_name        = var.pvs_image_name
}

module "powervs_workspace_eu_de_2" {
  providers = {
    ibm = ibm.powervs_eu-de-2
  }
  source            = "./modules//pvs_workspace"
  datacenter        = "eu-de-2"
  pi_workspace_name = "${var.prefix}-boskos-eu-de-2"
  resource_group_id = module.resource_group.k8s_resource_group_id
  image_name        = var.pvs_image_name
}

module "powervs_workspace_lon04" {
  providers = {
    ibm = ibm.powervs_lon04
  }
  source            = "./modules//pvs_workspace"
  datacenter        = "lon04"
  pi_workspace_name = "${var.prefix}-boskos-lon04"
  resource_group_id = module.resource_group.k8s_resource_group_id
  image_name        = var.pvs_image_name
}

module "powervs_workspace_lon06" {
  providers = {
    ibm = ibm.powervs_lon06
  }
  source            = "./modules//pvs_workspace"
  datacenter        = "lon06"
  pi_workspace_name = "${var.prefix}-boskos-lon06"
  resource_group_id = module.resource_group.k8s_resource_group_id
  image_name        = var.pvs_image_name
}

module "powervs_workspace_mad02" {
  providers = {
    ibm = ibm.powervs_mad02
  }
  source            = "./modules//pvs_workspace"
  datacenter        = "mad02"
  pi_workspace_name = "${var.prefix}-boskos-mad02"
  resource_group_id = module.resource_group.k8s_resource_group_id
  image_name        = var.pvs_image_name
}

module "powervs_workspace_syd04" {
  providers = {
    ibm = ibm.powervs_syd04
  }
  source            = "./modules//pvs_workspace"
  datacenter        = "syd04"
  pi_workspace_name = "${var.prefix}-boskos-syd04"
  resource_group_id = module.resource_group.k8s_resource_group_id
  image_name        = var.pvs_image_name
}

module "powervs_workspace_syd05" {
  providers = {
    ibm = ibm.powervs_syd05
  }
  source            = "./modules//pvs_workspace"
  datacenter        = "syd05"
  pi_workspace_name = "${var.prefix}-boskos-syd05"
  resource_group_id = module.resource_group.k8s_resource_group_id
  image_name        = var.pvs_image_name
}

module "powervs_workspace_tok04" {
  providers = {
    ibm = ibm.powervs_tok04
  }
  source            = "./modules//pvs_workspace"
  datacenter        = "tok04"
  pi_workspace_name = "${var.prefix}-boskos-tok04"
  resource_group_id = module.resource_group.k8s_resource_group_id
  image_name        = var.pvs_image_name
}

module "powervs_workspace_osa21" {
  providers = {
    ibm = ibm.powervs_osa21
  }
  source            = "./modules//pvs_workspace"
  datacenter        = "osa21"
  pi_workspace_name = "${var.prefix}-boskos-osa21"
  resource_group_id = module.resource_group.k8s_resource_group_id
  image_name        = var.pvs_image_name
}

module "powervs_workspace_che01" {
  providers = {
    ibm = ibm.powervs_che01
  }
  source            = "./modules//pvs_workspace"
  datacenter        = "che01"
  pi_workspace_name = "${var.prefix}-boskos-che01"
  resource_group_id = module.resource_group.k8s_resource_group_id
  image_name        = var.pvs_image_name
}
