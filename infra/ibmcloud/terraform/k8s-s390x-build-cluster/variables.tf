/*
Copyright 2025 The Kubernetes Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
variable "ibmcloud_api_key" {
  type = string
}
variable "region" {
  description = "IBM Cloud region to deploy the cluster"
  default     = "eu-de"
}
variable "ssh_public_key_path" {
  description = "Path to your public SSH key"
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_private_key_path" {
  description = "Path to your private SSH key"
  default     = "~/.ssh/id_rsa"
}
variable "ssh_connection_retries" {
  description = "Number of times to retry SSH connection"
  default     = 30
}

variable "ssh_retry_delay" {
  description = "Delay between SSH connection retries in seconds"
  default     = 10
}
variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to access bastion hosts via SSH"
  type        = string
  default     = "0.0.0.0/0" # Restrict this in production!
}
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