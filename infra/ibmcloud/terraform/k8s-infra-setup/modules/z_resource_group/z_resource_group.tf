resource "ibm_resource_group" "conformance_resource_group" {
  name = "${var.prefix_z}-rg-conformance-test"
}
resource "ibm_resource_group" "unit_resource_group" {
  name = "${var.prefix_z}-rg-unit-test"
}
resource "ibm_resource_group" "e2e_resource_group" {
  name = "${var.prefix_z}-rg-e2e-test"
}
