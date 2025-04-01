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
output "conformance_resource_group_id" {
  value = ibm_resource_group.conformance_resource_group.id
}
output "unit_resource_group_id" {
  value = ibm_resource_group.unit_resource_group.id
}
output "e2e_resource_group_id" {
  value = ibm_resource_group.e2e_resource_group.id
}

output "build_resource_group_id" {
  value = ibm_resource_group.build_resource_group.id
}