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

"""Roll CSI pods only when their Secret data changes; never log credentials."""

import hashlib
import json
import os
from pathlib import Path
import ssl
import urllib.error
import urllib.request

ANNOTATION = "storage.ibmcloud.k8s.io/credential-sha256"


def reconcile(request, namespace):
    secret = request(f"/api/v1/namespaces/{namespace}/secrets/storage-secret-store")
    data = secret.get("data", {}).get("slclient.toml")
    if not data:
        raise ValueError("storage-secret-store is missing slclient.toml")
    digest = hashlib.sha256(data.encode()).hexdigest()
    for kind, name in (("deployments", "ibm-vpc-block-csi-controller"),
                       ("daemonsets", "ibm-vpc-block-csi-node")):
        path = f"/apis/apps/v1/namespaces/{namespace}/{kind}/{name}"
        workload = request(path)
        annotations = workload["spec"]["template"]["metadata"].get("annotations", {})
        if annotations.get(ANNOTATION) == digest:
            print(f"{kind}/{name}: credential unchanged")
            continue
        patch = {
            "metadata": {"resourceVersion": workload["metadata"]["resourceVersion"]},
            "spec": {"template": {"metadata": {"annotations": {ANNOTATION: digest}}}},
        }
        request(path, patch)
        print(f"{kind}/{name}: requested credential reload")


def main():
    service_account = Path("/var/run/secrets/kubernetes.io/serviceaccount")
    token = (service_account / "token").read_text().strip()
    context = ssl.create_default_context(cafile=str(service_account / "ca.crt"))

    def request(path, patch=None):
        headers = {"Authorization": f"Bearer {token}", "Accept": "application/json"}
        payload = None
        if patch is not None:
            headers["Content-Type"] = "application/merge-patch+json"
            payload = json.dumps(patch).encode()
        req = urllib.request.Request(
            "https://kubernetes.default.svc" + path, data=payload,
            headers=headers, method="PATCH" if patch is not None else "GET")
        with urllib.request.urlopen(req, context=context, timeout=15) as response:
            return json.load(response)

    reconcile(request, os.environ["POD_NAMESPACE"])


if __name__ == "__main__":
    try:
        main()
    except urllib.error.HTTPError as error:
        # Do not print an HTTP response body that could contain a Secret.
        raise SystemExit(f"Credential reload API request failed: HTTP {error.code}")
