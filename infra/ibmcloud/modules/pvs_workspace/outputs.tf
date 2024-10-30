output "pvs_workspace_id" {
  value = ibm_pi_workspace.powervs_service_instance.id
}

output "pvs_workspace_crn" {
  value = ibm_pi_workspace.powervs_service_instance.crn
}
