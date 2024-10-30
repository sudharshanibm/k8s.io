# _TF Module: Cloud Object Storage_

- **IBM Cloud Object Storage Instance:**
  - Created using `ibm_resource_instance` with:
    - Name: specified by `local.cos_instance_name`
    - Resource group ID: specified by `var.resource_group_id`
    - Service: "cloud-object-storage"
    - Plan: "standard"
    - Location: "global"

- **COS Bucket Creation:**
  - Defined using `ibm_cos_bucket` with:
    - Bucket name: specified by `local.cos_bucket_name`
    - Linked to the COS instance
    - Cross-region location: "us"
    - Storage class: "smart"

- **Bucket Lifecycle Management:**
  - Configured using `ibm_cos_bucket_lifecycle_configuration` with:
    - Lifecycle rule ID: "k8s-lifecycle-rule"
    - Abort incomplete multipart uploads after 7 days
    - Expire objects after 45 days
    - Filter: applies to all objects (prefix: "")

- **Public Access Configuration:**
  - IAM access group data resource: retrieves "Public Access" group
  - Policy created with `ibm_iam_access_group_policy` that:
    - Grants "Content Reader" role
    - Applies to the created bucket
    - Enables public read access

This configuration establishes a Cloud Object Storage (COS) instance and bucket within IBM Cloud, enabling secure storage and management of data within the specified resource group.
