# _TF: IBM K8s Account Infrastructure_
This Terraform configuration sets up an organized structure for deploying various IBM Cloud resources using modules. 

1. **Resource Group Creation:**
   - The `resource_group` module creates a resource group in IBM Cloud.

2. **Custom IAM Role:**
   - The `iam_custom_role` module creates custom IAM roles with defined permissions that are specifically tailored to a particular IBM Cloud service or set of services.

3. **Service ID:**
   - The `service_ids` module creates a service id, associating them with the previously created resource group.

4. **IAM Access Groups:**
   - The `iam_access_groups` module creates access group that depends on the custom roles associating them with the previously created resource group.

5. **Cloud Object Storage (COS) Setup:**
   - The `ibm_cos` module provisions a Cloud Object Storage instance and bucket, then associates them with the previously created resource group.

6. **Secrets Manager Configuration:**
   - The `secrets_manager` module configures a Secrets Manager instance, using parameters like the resource group ID, access group ID, and COS instance details from previously created COS module.

7. **Power Virtual Server Workspace:**
   - The `powervs_workspace_<datacenter>` module provisions a Power Virtual Server workspace in the specific datacenter, using a specific provider configuration and it is associated with the previously created resource group.
   - Additionally, the configuration includes the creation of a housekeeping PowerVS workspace, which is a dedicated resource for managing infrastructure tasks.
   - An SSH key is also created and associated with the PowerVS workspaces to enable secure access to virtual machines and other resources within the workspaces.
