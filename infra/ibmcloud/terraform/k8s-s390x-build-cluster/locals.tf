locals {
  clusters = {
    conformance = {
      vpc            = "k8s-vpc-conformance"
      subnet         = "k8s-subnet-conformance"
      resource_group = "rg-conformance-test"
      zone           = "eu-de-1"
    }
    e2e = {
      vpc            = "k8s-vpc-e2e"
      subnet         = "k8s-subnet-e2e"
      resource_group = "rg-e2e-test"
      zone           = "eu-de-2"
    }
    unit = {
      vpc            = "k8s-vpc-unit"
      subnet         = "k8s-subnet-unit"
      resource_group = "rg-unit-test"
      zone           = "eu-de-3"
    }
  }
}
