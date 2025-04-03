resource "ibm_is_instance" "control_plane_nodes" {
  for_each       = local.clusters
  name           = "control-plane-${each.key}-node"
  image          = var.instance_image_id
  profile        = var.instance_profile
  vpc            = data.ibm_is_vpc.vpcs[each.key].id
  zone           = each.value.zone
  resource_group = data.ibm_resource_group.resource_groups[each.key].id
  keys           = [ibm_is_ssh_key.ssh_key[each.key].id]
  primary_network_interface {
    subnet          = data.ibm_is_subnet.subnets[each.key].id
    security_groups = [data.ibm_is_security_groups.sgs[each.key].security_groups[0].id]
  }
}

resource "null_resource" "control_plane_setup" {
  for_each   = local.clusters
  depends_on = [ibm_is_instance.control_plane_nodes, ibm_is_instance.bastions]

  connection {
    type         = "ssh"
    user         = "root"
    host         = ibm_is_instance.control_plane_nodes[each.key].primary_network_interface[0].primary_ipv4_address
    private_key  = file(var.ssh_private_key_path)
    bastion_host = ibm_is_instance.bastions[each.key].primary_network_interface[0].primary_ipv4_address
  }

  provisioner "remote-exec" {
    inline = [<<EOF
sudo sed -i.bak -e 's/^ - set_hostname/# - set_hostname/' -e 's/^ - update_hostname/# - update_hostname/' /etc/cloud/cloud.cfg
sudo hostnamectl set-hostname --static control-plane-${each.key}.k8s.ibm.com
echo 'HOSTNAME=control-plane-${each.key}.k8s.ibm.com' | sudo tee -a /etc/sysconfig/network > /dev/null
sudo hostname -F /etc/hostname
EOF
    ]
  }
}
