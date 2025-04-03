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

resource "ibm_is_ssh_key" "ssh_key" {
  for_each       = local.clusters
  name           = "bastion-ssh-key-${each.key}"
  public_key     = file(var.ssh_public_key_path)
  resource_group = data.ibm_resource_group.resource_groups[each.key].id
}

resource "ibm_is_instance" "bastions" {
  for_each       = local.clusters
  name           = "bastion-${each.key}"
  image          = var.instance_image_id
  profile        = var.instance_profile
  vpc            = data.ibm_is_vpc.vpcs[each.key].id
  zone           = each.value.zone
  resource_group = data.ibm_resource_group.resource_groups[each.key].id
  keys           = [ibm_is_ssh_key.ssh_key[each.key].id]
  primary_network_interface {
    subnet          = data.ibm_is_subnet.subnets[each.key].id
    security_groups = [data.ibm_is_security_groups.sgs[each.key].security_groups[0].id]
  }
}
