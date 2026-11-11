# Copyright 2026 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import copy
import hashlib
import importlib.util
from pathlib import Path
import unittest

spec = importlib.util.spec_from_file_location(
    "reload_credentials", Path(__file__).parents[1] / "reload-credentials.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class ReloadCredentials(unittest.TestCase):
    def run_reconcile(self, data, existing_hash=None):
        patches = []
        workload = {"metadata": {"resourceVersion": "123"},
                    "spec": {"template": {"metadata": {"annotations": {}}}}}
        if existing_hash:
            workload["spec"]["template"]["metadata"]["annotations"][module.ANNOTATION] = existing_hash

        def request(path, patch=None):
            if patch is not None:
                patches.append((path, patch))
                return {}
            if "/secrets/" in path:
                return {"data": data, "metadata": {"resourceVersion": "unrelated-update"}}
            return copy.deepcopy(workload)

        module.reconcile(request, "kube-system")
        return patches

    def test_secret_metadata_change_does_not_restart_workloads(self):
        value = "example-base64-payload"
        digest = hashlib.sha256(value.encode()).hexdigest()
        self.assertEqual(self.run_reconcile({"slclient.toml": value}, digest), [])

    def test_credential_change_updates_only_both_named_workloads(self):
        patches = self.run_reconcile({"slclient.toml": "changed-payload"}, "old")
        self.assertEqual([p.rsplit("/", 1)[-1] for p, _ in patches],
                         ["ibm-vpc-block-csi-controller", "ibm-vpc-block-csi-node"])
        for _, patch in patches:
            self.assertEqual(patch["metadata"]["resourceVersion"], "123")
            self.assertNotIn("changed-payload", str(patch))

    def test_missing_credential_fails_before_rollout(self):
        with self.assertRaisesRegex(ValueError, "missing slclient.toml"):
            self.run_reconcile({})


if __name__ == "__main__":
    unittest.main()
