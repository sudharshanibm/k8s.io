locals {
  cos_instance_name = "${var.prefix}-cos-ppc64le"
  cos_bucket_name   = "${var.prefix}-bucket-ppc64le"
}

resource "ibm_resource_instance" "cos_instance" {
  name              = local.cos_instance_name
  resource_group_id = var.resource_group_id
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
}

resource "ibm_cos_bucket" "cos_bucket" {
  bucket_name           = local.cos_bucket_name
  resource_instance_id  = ibm_resource_instance.cos_instance.id
  cross_region_location = "us"
  storage_class         = "smart"
}

resource "ibm_cos_bucket_lifecycle_configuration" "lifecycle" {
  bucket_crn      = ibm_cos_bucket.cos_bucket.crn
  bucket_location = ibm_cos_bucket.cos_bucket.cross_region_location
  lifecycle_rule {
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    expiration {
      days = 14
    }
    filter {
      prefix = "ci/"
    }
    rule_id = "k8s-lifecycle-rule"
    status  = "enable"
  }
}

data "ibm_iam_access_group" "public_access_group" {
  access_group_name = "Public Access"
}

resource "ibm_iam_access_group_policy" "public_access_policy" {
  access_group_id = data.ibm_iam_access_group.public_access_group.groups[0].id
  roles           = ["Content Reader"]
  resources {
    resource             = ibm_cos_bucket.cos_bucket.bucket_name
    resource_instance_id = ibm_resource_instance.cos_instance.guid
    resource_type        = "bucket"
    service              = "cloud-object-storage"
  }
}
