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
resource "ibm_is_instance" "bastion" {
  count          = var.bastion.count
  name           = "bastion-s390x-${count.index + 1}"
  vpc            = data.ibm_is_vpc.vpc.id
  zone           = var.zone
  profile        = var.bastion.profile
  image          = var.image_id
  keys           = [ibm_is_ssh_key.k8s_ssh_key.id]
  resource_group = data.ibm_resource_group.resource_group.id

  primary_network_interface {
    subnet          = data.ibm_is_subnet.subnet.id
    security_groups = [data.ibm_is_security_group.bastion_sg.id]
  }

  boot_volume {
    name = "boot-vol-bastion-${count.index}"
    size = var.bastion.boot_volume.size
  }
}

resource "ibm_is_floating_ip" "bastion_fip" {
  count          = var.bastion.count
  name           = "bastion-fip-${count.index}"
  target         = ibm_is_instance.bastion[count.index].primary_network_interface[0].id
  resource_group = data.ibm_resource_group.resource_group.id
}