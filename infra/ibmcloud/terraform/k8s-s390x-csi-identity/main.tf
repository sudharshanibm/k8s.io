/*
Copyright 2026 The Kubernetes Authors.

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

data "ibm_resource_group" "vpc" {
  name = var.resource_group_name
}

resource "ibm_iam_access_group" "vpc_csi" {
  name        = "${var.name_prefix}-vpc-csi-access"
  description = "Resource-group-scoped access group for the IBM s390x VPC Block CSI driver."

  lifecycle {
    precondition {
      condition     = data.ibm_resource_group.vpc.account_id == var.expected_account_id
      error_message = "The authenticated IBM Cloud account does not match expected_account_id."
    }
  }
}

resource "ibm_iam_access_group_policy" "vpc_csi" {
  access_group_id = ibm_iam_access_group.vpc_csi.id
  roles           = ["Editor", "Writer"]

  resources {
    service           = "is"
    resource_group_id = data.ibm_resource_group.vpc.id
  }
}

resource "ibm_iam_access_group_policy" "resource_group_viewer" {
  access_group_id = ibm_iam_access_group.vpc_csi.id
  roles           = ["Viewer"]

  resources {
    resource_type = "resource-group"
    resource      = data.ibm_resource_group.vpc.id
  }
}

resource "ibm_sm_iam_credentials_secret" "vpc_csi" {
  instance_id     = var.secrets_manager_id
  region          = var.region
  name            = "${var.name_prefix}-vpc-csi-api-key"
  description     = "Rotating API key used by the IBM s390x VPC Block CSI driver."
  access_groups   = [ibm_iam_access_group.vpc_csi.id]
  labels          = ["s390x-vpc-csi", "rotate:true"]
  secret_group_id = "default"
  ttl             = var.credential_ttl_seconds
  reuse_api_key   = true

  # The existing ibmcloud-secret-rotator CronJob selects rotate:true every two
  # hours. Reuse its IAM engine and schedule; do not configure a second rotator
  # or take ownership of the shared IAM engine from this independent state.
  depends_on = [
    ibm_iam_access_group_policy.vpc_csi,
    ibm_iam_access_group_policy.resource_group_viewer,
  ]
}
