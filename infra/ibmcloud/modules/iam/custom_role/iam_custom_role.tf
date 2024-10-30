resource "ibm_iam_custom_role" "pvs" {
  name         = "CustomRolePVS"
  display_name = "CustomRolePVS"
  service      = "power-iaas.workspace"
  actions = [
    "power-iaas.network.create",
    "power-iaas.network.delete",
    "power-iaas.pvm-instance.create",
    "power-iaas.pvm-instance.delete",
    "power-iaas.cloud-instance-image.create",
    "power-iaas.cloud-instance-image.delete",
    "power-iaas.cloud-instance-image.list",
    "power-iaas.cloud-instance-image.read",
    "power-iaas.cloud-instance.read",
    "power-iaas.cos-image.create",
    "power-iaas.cos-image.read"
  ]
}

resource "ibm_iam_custom_role" "sm" {
  name         = "CustomRoleSM"
  display_name = "CustomRoleSM"
  service      = "secrets-manager"
  actions = [
    "secrets-manager.secrets.list",
    "secrets-manager.secret.read",
  ]
}
