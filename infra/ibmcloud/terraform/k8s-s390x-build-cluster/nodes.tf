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
resource "ibm_is_instance" "control_plane" {
  count          = var.control_plane.count
  name           = "master-s390x-${count.index + 1}"
  vpc            = data.ibm_is_vpc.vpc.id
  zone           = var.zone
  profile        = var.control_plane.profile
  image          = var.image_id
  keys           = [ibm_is_ssh_key.k8s_ssh_key.id]
  resource_group = data.ibm_resource_group.resource_group.id

  primary_network_interface {
    subnet          = data.ibm_is_subnet.subnet.id
    security_groups = [data.ibm_is_security_group.master_sg.id]
  }

  boot_volume {
    name = "boot-vol-master-${count.index + 1}"
    size = var.control_plane.boot_volume.size
  }
}

resource "ibm_is_instance" "compute" {
  count          = var.compute.count
  name           = "worker-s390x-${count.index + 1}"
  vpc            = data.ibm_is_vpc.vpc.id
  zone           = var.zone
  profile        = var.compute.profile
  image          = var.image_id
  keys           = [ibm_is_ssh_key.k8s_ssh_key.id]
  resource_group = data.ibm_resource_group.resource_group.id

  primary_network_interface {
    subnet          = data.ibm_is_subnet.subnet.id
    security_groups = [data.ibm_is_security_group.worker_sg.id]
  }

  boot_volume {
    name = "boot-vol-worker-${count.index + 1}"
    size = var.compute.boot_volume.size
  }
}