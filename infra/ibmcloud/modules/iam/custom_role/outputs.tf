output "k8s_custom_role_pvs_crn" {
  value = ibm_iam_custom_role.pvs.crn
}

output "k8s_custom_role_sm_crn" {
  value = ibm_iam_custom_role.sm.crn
}
