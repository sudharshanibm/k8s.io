// IBM Cloud API key for authenticating with IBM Cloud services
variable "api_key" {
  type      = string
  sensitive = true
}

variable "prefix" {
  type    = string
  default = "k8s-infra"
}

# The name of the image to be imported from the IBM Cloud catalog for the PowerVS instance in the boot section
variable "pvs_image_name" {
  type    = string
  default = "CentOS-Stream-9"
}
variable "target_architecture" {
  description = "Target architecture for resource creation"
  type        = string
  default     = "ppcle" # Set your default architecture here
}

variable "resource_group_id" {
  type = string
  default = "XXXXXXXXXXXXX"
}

variable "vpc_api_key" {
  sensitive = true
}

variable "vpc_resource_group" {
  default = "default"
}

variable "vpc_ssh_key" {}

variable "vpc_name" {
  type        = string
  description = "(optional) Specify existing VPC name. If none is provided, it will create a new VPC named {cluster_name}-vpc"
  default     = ""
}

variable "vpc_subnet_name" {
  type        = string
  description = "(optional) Specify existing subnet name. If none is provided, it will create a new subnet named {cluster_name}-subnet. This must be provided if vpc_name has been set"
  default     = ""
}

variable "node_image" {
  default = "ibm-ubuntu-22-04-2-minimal-s390x-1"
}

variable "node_profile" {
  default = "bz2-2x8"
}

variable "vpc_region" {
  default = "eu-de"
}

variable "vpc_zone" {
  default = "eu-de-1"
}

variable "cluster_name" {
  description = "K8s cluster name"
  default = "s390x-kube-test"
}

variable "release_marker" {
  description = "Kubernetes release marker"
  default = "ci/latest"
}

variable "build_version" {
  description = "Kubernetes Build Number"
}

variable "ssh_private_key" {
  description = "SSH Private Key file's complete path"
  default = "~/.ssh/id_rsa"
}

variable "kubeconfig_path" {
  description = "File path to write the kubeconfig content for the deployed cluster"
  default = "~/.kube/config"
}

variable "workers_count" {
  description = "Number of workers in the cluster"
  default = 1
}

variable "bootstrap_token" {
  description = "Kubeadm bootstrap token used for installing and joining the cluster"
  default = "abcdef.0123456789abcdef"
}

