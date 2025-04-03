locals {
  key    = var.ibmcloud_api_key
  region = "eu-de"
  zone   = "eu-de-1"
}

provider "ibm" {
  ibmcloud_api_key = local.key
  region           = local.region
  zone             = local.zone
}

provider "ibm" {
  alias            = "vpc"
  ibmcloud_api_key = local.key
  region           = "eu-de"
}

provider "ibm" {
  alias            = "vpcs"
  ibmcloud_api_key = local.key
  region           = "eu-de"
}
