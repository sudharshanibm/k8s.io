# _TF Module: IAM Service ID_

- **IAM Service ID:**
  - Created using `ibm_iam_service_id` with:
    - **Name:** Specified by `local.iam_service_id_name`

- **IAM Service API Key:**
  - Defined using `ibm_iam_service_api_key` with:
    - **Name:** Specified by `local.service_id_apikey_name`
    - **IAM Service ID:** References the ID of the created service ID (`ibm_iam_service_id.service_id.iam_id`)

- **Service Policy:**
  - Defined using `ibm_iam_service_policy` with:
    - **IAM Service ID:** References the created service id
    - **Roles:** Specified by `CustomRoleSM`
    - **Resources Configuration:**
      - **Service:** "secrets-manager"
      - **Resource Group ID:** Specified by `var.resource_group_id`

This configuration establishes a service ID and generates an API key for programmatic access, assigning it a custom role that grants permissions to manage resources within the specified resource group for the Secrets Manager service.
