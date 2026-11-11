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
# Host runtime disks are static infrastructure; application PVC disks belong to CSI.
resource "ibm_is_volume" "worker_data" {
  for_each       = var.worker_data_volumes
  name           = each.value.name
  profile        = each.value.profile
  capacity       = each.value.capacity
  zone           = var.zone
  resource_group = data.ibm_resource_group.resource_group.id

  lifecycle {
    prevent_destroy = true
  }
}

resource "ibm_is_instance_volume_attachment" "worker_data" {
  for_each                         = var.worker_data_volumes
  instance                         = ibm_is_instance.compute[each.value.worker].id
  name                             = each.value.attachment_name
  volume                           = ibm_is_volume.worker_data[each.key].id
  delete_volume_on_instance_delete = false
  # Provider default is true: explicitly preserve disks if an attachment is removed.
  delete_volume_on_attachment_delete = false

  lifecycle {
    prevent_destroy = true
  }
}
