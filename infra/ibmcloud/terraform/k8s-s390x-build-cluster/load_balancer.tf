resource "ibm_is_lb" "control_plane_lbs" {
  for_each       = local.clusters
  name           = "k8s-control-plane-lb-${each.key}"
  resource_group = data.ibm_resource_group.resource_groups[each.key].id
  subnets        = [data.ibm_is_subnet.subnets[each.key].id]
  type           = "public"
}

resource "ibm_is_lb_listener" "api_listener" {
  for_each     = local.clusters
  lb           = ibm_is_lb.control_plane_lbs[each.key].id
  port         = 6443
  protocol     = "tcp"
  default_pool = ibm_is_lb_pool.api_pools[each.key].id
}

resource "ibm_is_lb_pool" "api_pools" {
  for_each       = local.clusters
  name           = "api-server-${each.key}"
  lb             = ibm_is_lb.control_plane_lbs[each.key].id
  algorithm      = "round_robin"
  protocol       = "tcp"
  health_delay   = 60
  health_retries = 5
  health_timeout = 30
  health_type    = "tcp"
}

resource "ibm_is_lb_pool_member" "api_members" {
  for_each = local.clusters

  lb             = ibm_is_lb.control_plane_lbs[each.key].id
  pool           = ibm_is_lb_pool.api_pools[each.key].id
  port           = 6443
  target_address = ibm_is_instance.control_plane_nodes[each.key].primary_network_interface[0].primary_ipv4_address
}
