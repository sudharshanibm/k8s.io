/*
Copyright 2026 The Kubernetes Authors.

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

variable "expected_account_id" {
  description = "IBM Cloud account ID that must match the authenticated identity before resources can be created."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{32}$", var.expected_account_id))
    error_message = "expected_account_id must be a 32-character IBM Cloud account ID."
  }
}

variable "ibmcloud_api_key" {
  description = "IBM Cloud API key used only by Terraform to manage the CSI identity."
  type        = string
  sensitive   = true
}

variable "secrets_manager_id" {
  description = "GUID of the existing IBM Cloud Secrets Manager instance."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.secrets_manager_id))
    error_message = "secrets_manager_id must be an IBM Cloud Secrets Manager GUID."
  }
}

variable "region" {
  description = "IBM Cloud region containing the VPC and Secrets Manager instance."
  type        = string
  default     = "eu-de"
}

variable "resource_group_name" {
  description = "Resource group containing the s390x build-cluster VPC resources."
  type        = string
  default     = "rg-build-cluster"
}

variable "name_prefix" {
  description = "Prefix used for the dedicated CSI access group and IAM credential secret."
  type        = string
  default     = "k8s-s390x"
}

variable "credential_ttl_seconds" {
  description = "Credential lease in seconds; must exceed the existing two-hour rotation and External Secrets refresh intervals."
  type        = string
  default     = "43200"

  validation {
    condition = try(
      tonumber(var.credential_ttl_seconds) >= 10800 &&
      tonumber(var.credential_ttl_seconds) <= 7776000 &&
      floor(tonumber(var.credential_ttl_seconds)) == tonumber(var.credential_ttl_seconds),
      false,
    )
    error_message = "credential_ttl_seconds must be an integer between 10800 seconds (3 hours) and 7776000 seconds (90 days)."
  }
}
