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
