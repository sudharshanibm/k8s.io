resource "ibm_iam_access_group" "access_group" {
  name = "${var.prefix}-ppc64le"
}

resource "ibm_iam_access_group_policy" "policy_pvs" {
  access_group_id = ibm_iam_access_group.access_group.id
  roles           = ["CustomRolePVS"]

  resources {
    service           = "power-iaas"
    resource_group_id = var.resource_group_id
  }
}
