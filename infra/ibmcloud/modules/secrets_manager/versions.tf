terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }
  }
}
