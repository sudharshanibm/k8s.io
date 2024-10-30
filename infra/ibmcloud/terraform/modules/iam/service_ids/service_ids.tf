locals {
  iam_service_id_name    = "${var.prefix}-iam-ppc64le"
  service_id_apikey_name = "${var.prefix}-apikey-ppc64le"
}

resource "ibm_iam_service_id" "service_id" {
  name = local.iam_service_id_name
}

resource "ibm_iam_service_api_key" "service_id_apikey" {
  name           = local.service_id_apikey_name
  iam_service_id = ibm_iam_service_id.service_id.iam_id
}

resource "ibm_iam_service_policy" "policy_sm" {
  iam_service_id = ibm_iam_service_id.service_id.id
  roles          = ["CustomRoleSM"]

  resources {
    service           = "secrets-manager"
    resource_group_id = var.resource_group_id
  }
}
