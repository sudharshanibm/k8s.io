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
resource "ibm_is_lb" "load_balancer" {
  name           = "k8s-s390x-lb"
  type           = "public"
  subnets        = [data.ibm_is_subnet.subnet.id]
  resource_group = data.ibm_resource_group.resource_group.id
}

resource "ibm_is_lb_pool" "api_pool" {
  lb             = ibm_is_lb.load_balancer.id
  name           = "k8s-api-pool"
  protocol       = "tcp"
  algorithm      = "round_robin"
  health_delay   = 30
  health_retries = 3
  health_timeout = 10
  health_type    = "tcp"
}

resource "ibm_is_lb_listener" "api_listener" {
  lb           = ibm_is_lb.load_balancer.id
  port         = 6443
  protocol     = "tcp"
  default_pool = ibm_is_lb_pool.api_pool.id
}

resource "ibm_is_lb_pool_member" "api_member" {
  count          = var.control_plane.count
  lb             = ibm_is_lb.load_balancer.id
  pool           = element(split("/", ibm_is_lb_pool.api_pool.id), 1)
  port           = 6443
  target_address = ibm_is_instance.control_plane[count.index].primary_network_interface[0].primary_ipv4_address
}