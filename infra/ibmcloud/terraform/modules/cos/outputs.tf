output "k8s_cos_instance_guid" {
  value = ibm_resource_instance.cos_instance.guid
}

output "k8s_cos_instance_id" {
  value = ibm_resource_instance.cos_instance.id
}

output "k8s_cos_bucket_id" {
  value = ibm_cos_bucket.cos_bucket.id
}

output "k8s_cos_bucket_crn" {
  value = ibm_cos_bucket.cos_bucket.crn
}
