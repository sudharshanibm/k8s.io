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
# Adopt already-attached production disks. Planning imports only reads IBM Cloud.
# Review a saved plan; do not apply if any VSI/disk/attachment operation is proposed.
locals {
  existing_worker_disks = {
    "1" = {
      volume     = "r010-dbd783c9-882b-470c-813d-60a6d810d7d3"
      attachment = "02b7_76fdf98b-3180-4ebf-b11d-f0cc91b35a0f/02b7-a0a455a6-928a-4c49-a327-c278c699dfb0"
    }
    "2" = {
      volume     = "r010-fae7fad9-39c6-479a-a449-3272e1287560"
      attachment = "02b7_f3074086-02d3-440a-a528-b438b5a8caf9/02b7-b1c47ff9-ccec-4d11-8e01-cfdd1869dc51"
    }
    "3" = {
      volume     = "r010-a2eab6a4-97e1-480b-95f3-bfc88b61d234"
      attachment = "02b7_54224699-cb72-47d3-8239-0f28d0a84a72/02b7-e841cfbd-1112-4cf7-9954-97dfc8720a31"
    }
    "3-legacy-gp" = {
      volume     = "r010-e099145f-047e-416f-aa84-3de63ace258b"
      attachment = "02b7_54224699-cb72-47d3-8239-0f28d0a84a72/02b7-d2b1fdb8-5547-4a8f-b51d-5f8d028e3997"
    }
    "4" = {
      volume     = "r010-7f58e076-3b62-46da-b3b9-8fd5d9dc63e6"
      attachment = "02b7_858e76ee-c964-49ad-a0f2-44cc59c95f2c/02b7-eb05bb6e-a4ca-445a-b5fc-6e9f9ef25d76"
    }
    "5" = {
      volume     = "r010-78640cc3-93ff-4196-800e-cf7a507b882f"
      attachment = "02b7_f2fd6e8b-1cd0-4607-87f0-a2e869ff243e/02b7-6be7e757-b07d-43dd-be59-d63cbef42681"
    }
    "6" = {
      volume     = "r010-0e6483b1-564f-4f0e-aa92-120a4983ed17"
      attachment = "02b7_76a9d606-d5a3-4a20-8182-2d685abc2afc/02b7-83b74f36-cac4-4f06-a4f6-6cd21fa997d9"
    }
    "7" = {
      volume     = "r010-83644877-cace-4093-8ca6-707dc35651af"
      attachment = "02b7_efcdbb6b-5043-4daa-8d61-f51caaa612be/02b7-8c21c8aa-84be-4045-bbdd-c961a42f47c1"
    }
    "8" = {
      volume     = "r010-c34bc67b-83fa-4871-8266-c501859dd090"
      attachment = "02b7_3d7f8e5e-3e9f-4426-89b8-ee5bd02f3c36/02b7-458b7715-b72b-4781-af76-c3a65433cc4e"
    }
    "9" = {
      volume     = "r010-f5b2d66c-94a7-4b9f-93d8-a3dae4895d55"
      attachment = "02b7_7869f481-0e73-4c9c-ae27-5e384dd8336d/02b7-ec2608a4-9e5b-4137-a03b-3141fe6ab99d"
    }
    "10" = {
      volume     = "r010-79914334-7a80-41f2-ad14-3a75df239406"
      attachment = "02b7_2453fd3e-5ba4-45c6-bdb7-2b94cff57c0f/02b7-39204d65-a05b-46b7-8887-2411645f19b3"
    }
  }
}

import {
  for_each = local.existing_worker_disks
  to       = ibm_is_volume.worker_data[each.key]
  id       = each.value.volume
}

import {
  for_each = local.existing_worker_disks
  to       = ibm_is_instance_volume_attachment.worker_data[each.key]
  id       = each.value.attachment
}
