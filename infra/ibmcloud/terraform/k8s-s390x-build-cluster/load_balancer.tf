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
resource "ibm_is_lb" "control_plane_lbs" {
  for_each       = local.clusters
  name           = "k8s-control-plane-lb-${each.key}"
  resource_group = data.ibm_resource_group.resource_groups[each.key].id
  subnets        = [data.ibm_is_subnet.subnets[each.key].id]
  type           = "public"
  profile        = "network-fixed"
}

resource "ibm_is_lb_pool" "api_pools" {
  for_each            = local.clusters
  name                = "api-server-${each.key}"
  lb                  = ibm_is_lb.control_plane_lbs[each.key].id
  algorithm           = "round_robin"
  protocol            = "tcp"
  health_delay        = 5
  health_retries      = 2
  health_timeout      = 2
  health_type         = "tcp"
  health_monitor_port = 6443
}

resource "ibm_is_lb_listener" "api_listener" {
  for_each     = local.clusters
  lb           = ibm_is_lb.control_plane_lbs[each.key].id
  port         = 6443
  protocol     = "tcp"
  default_pool = ibm_is_lb_pool.api_pools[each.key].pool_id
}

resource "ibm_is_lb_pool_member" "api_members" {
  for_each = {
    for cluster_key, cluster in local.clusters :
    cluster_key => {
      lb_id    = ibm_is_lb.control_plane_lbs[cluster_key].id
      pool_id  = ibm_is_lb_pool.api_pools[cluster_key].pool_id
      instance = ibm_is_instance.master_nodes[cluster_key]
    }
  }

  lb        = each.value.lb_id
  pool      = each.value.pool_id
  port      = 6443
  target_id = each.value.instance.id
  weight    = 50

  # Add all necessary dependencies
  depends_on = [
    ibm_is_lb.control_plane_lbs,
    ibm_is_lb_pool.api_pools,
    ibm_is_instance.master_nodes,
    ibm_is_lb_listener.api_listener
  ]

  timeouts {
    create = "45m"
    delete = "45m"
  }
}