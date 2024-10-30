locals {
  key    = var.api_key
  region = "us-south"
  zone   = "us-south"
}

provider "ibm" {
  ibmcloud_api_key = local.key
  region           = local.region
  zone             = local.zone
}

provider "ibm" {
  alias            = "powervs_dal12"
  ibmcloud_api_key = local.key
  region           = "dal"
  zone             = "dal12"
}

provider "ibm" {
  alias            = "powervs_us-south"
  ibmcloud_api_key = local.key
  region           = "us-south"
  zone             = "us-south"
}

provider "ibm" {
  alias            = "powervs_wdc06"
  ibmcloud_api_key = local.key
  region           = "wdc"
  zone             = "wdc06"
}

provider "ibm" {
  alias            = "powervs_us-east"
  ibmcloud_api_key = local.key
  region           = "us-east"
  zone             = "us-east"
}

provider "ibm" {
  alias            = "powervs_sao01"
  ibmcloud_api_key = local.key
  region           = "sao"
  zone             = "sao01"
}

provider "ibm" {
  alias            = "powervs_tor01"
  ibmcloud_api_key = local.key
  region           = "tor"
  zone             = "tor01"
}

provider "ibm" {
  alias            = "powervs_mon01"
  ibmcloud_api_key = local.key
  region           = "mon"
  zone             = "mon01"
}

provider "ibm" {
  alias            = "powervs_eu-de-1"
  ibmcloud_api_key = local.key
  region           = "eu-de"
  zone             = "eu-de-1"
}

provider "ibm" {
  alias            = "powervs_eu-de-2"
  ibmcloud_api_key = local.key
  region           = "eu-de"
  zone             = "eu-de-2"
}

provider "ibm" {
  alias            = "powervs_lon04"
  ibmcloud_api_key = local.key
  region           = "lon"
  zone             = "lon04"
}

provider "ibm" {
  alias            = "powervs_lon06"
  ibmcloud_api_key = local.key
  region           = "lon"
  zone             = "lon06"
}

provider "ibm" {
  alias            = "powervs_mad02"
  ibmcloud_api_key = local.key
  region           = "mad"
  zone             = "mad02"
}

provider "ibm" {
  alias            = "powervs_syd04"
  ibmcloud_api_key = local.key
  region           = "syd"
  zone             = "syd04"
}

provider "ibm" {
  alias            = "powervs_syd05"
  ibmcloud_api_key = local.key
  region           = "syd"
  zone             = "syd05"
}

provider "ibm" {
  alias            = "powervs_tok04"
  ibmcloud_api_key = local.key
  region           = "tok"
  zone             = "tok04"
}

provider "ibm" {
  alias            = "powervs_osa21"
  ibmcloud_api_key = local.key
  region           = "osa"
  zone             = "osa21"
}

provider "ibm" {
  alias            = "powervs_che01"
  ibmcloud_api_key = local.key
  region           = "che"
  zone             = "che01"
}
