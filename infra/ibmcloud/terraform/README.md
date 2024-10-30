# _TF: IBM K8s Account Infrastructure_
This Terraform configuration sets up an organized structure for deploying various IBM Cloud resources using modules. 

---
# To run the automation, follow these steps in order:

**1. Navigate to the correct directory**
<br> You need to be in the `terraform` directory to run the automation.

**2. Initialize Terraform**
<br> Execute the following command to initialize Terraform in your project directory. This command will download the necessary provider plugins and prepare the working environment.
```
terraform init
```

**3. Check the `variables.tf` file**
<br> Open the `variables.tf` file to review all the available variables. This file lists all customizable inputs for your Terraform configuration.

`API_KEY` is the only required variable that you must set in order to proceed. You can set this key either by adding it to your `vars.tf` file or by exporting it as an environment variable.

**Option 1:** Set in `vars.tf` file
Add the following line to the `vars.tf` file:
```
api_key = <YOUR_API_KEY>
```

**Option 2:** Export as an environment variable
Alternatively, you can export the API_KEY as an environment variable before running Terraform:
```
export TF_VAR_api_key="<YOUR_API_KEY>"
```

**4. Run Terraform Apply**
<br> After setting the necessary variables (particularly the API_KEY), execute the following command to apply the Terraform configuration and provision the infrastructure:
```
terraform apply
```
Terraform will display a plan of the actions it will take, and you'll be prompted to confirm the execution. Type `yes` to proceed.

**5 .Get Output Information**
<br> Once the infrastructure has been provisioned, use the terraform output command to list details about the provisioned resources.
```
terraform output
```
