# _TF Module: IAM Access Group_

- **IBM IAM Access Group:**
  - Created using `ibm_iam_access_group` with:
    - **Name:** Specified by `var.access_group_name`

- **Access Group Policy:**
  - Defined using `ibm_iam_access_group_policy` with:
    - **Access Group ID:** References the created access group
    - **Roles:** `CustomRolePVS`
    - **Resources Configuration:**
      - **Service:** "power-iaas"
      - **Resource Group ID:** Specified by `var.resource_group_id`

This configuration establishes an access group within IBM IAM, assigning it a custom role that grants permissions to manage resources within the specified resource group for the Power IaaS service.
