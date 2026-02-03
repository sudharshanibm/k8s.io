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

locals {
  bootstrap_admin_user     = "k8s-admin"
  bootstrap_ssh_public_key = replace(trimspace(data.ibm_sm_arbitrary_secret.ssh_public_key.payload), "\r", "")
  bootstrap_ssh_key_is_valid = (
    local.bootstrap_ssh_public_key != "" &&
    length(regexall("\n", local.bootstrap_ssh_public_key)) == 0 &&
    can(regex("^(ssh-[^\\s]+|ecdsa-[^\\s]+|sk-ssh-[^\\s]+)\\s+[A-Za-z0-9+/=]+(?:\\s+.*)?$", local.bootstrap_ssh_public_key))
  )
}
