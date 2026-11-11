# Adopt the existing s390x build-worker disks

This root describes five control-plane nodes, ten workers and one bastion in
`rg-build-cluster`, eu-de-1. It is distinct from disposable conformance clusters.
The production state/backend and all existing instance addresses are retained.

`worker-data-volumes.auto.tfvars.json` records the existing host disks and their
UUID/mount/runtime settings. `imports.tf` identifies eleven existing volumes and
eleven existing attachments: ten 100GiB `10iops-tier` containerd disks plus worker
3's separate 100GiB general-purpose legacy disk. The latter is an explicit legacy
entry, not a containerd disk. IBM reports 3000 IOPS on these disks; do not derive
an IOPS setting from the profile name.

Worker 5 deliberately retains its existing volume/attachment names and
`/mnt/s390x-infra-tier10/containerd` root. The other workers use
`/mnt/s390x-tier10-workerN/containerd`. Terraform neither formats filesystems nor
writes fstab, mounts disks, migrates runtime data or restarts containerd.

## Ownership and protection

- Static host disks/attachments: this root, separate `worker_data` resources.
- Host fstab and running containerd configuration: provider/operator node setup.
- Dynamic PVC disks/attachments: the CSI driver/Kubernetes. Never copy all current
  attachments into `ibm_is_instance.compute.volumes` or into this static map.
- Dedicated CSI IAM credential: the independent `k8s-s390x-csi-identity` root.

Existing instances and static disks/attachments have `prevent_destroy`. Instance
`user_data` is ignored after creation because these production nodes predate the
current cloud-init template; changing it would otherwise force replacement.
The template still applies to future creations. This does not retrofit its SSH
hardening onto existing nodes. Aggregate `volumes` is ignored because individual
static and dynamic attachments have separate owners. Image/profile/network/SSH
changes are not broadly ignored. An account precondition rejects the wrong RG
owner. Explicitly disabling both attachment deletion flags preserves the disks;
the provider's default `delete_volume_on_attachment_delete` is true.

Two unattached older pilot disks are outside this adoption. Keep them unchanged.
The retained 10GiB/20GiB CSI proof volumes are also excluded.

## Review before adoption

Use Terraform >=1.9 and the existing IBM ~>1.82.0 constraint (validated with
1.82.1). Initialize the exact production backend only with authorized credentials.
Review a saved plan privately; do not commit the plan or raw state. For modern
Terraform/COS clients, configure the backend's `skip_metadata_api_check`,
`skip_requesting_account_id` and `skip_s3_checksum` flags if required by your
existing COS setup; do not change backend bucket/key or migrate state.

The required plan result for this production inventory is:

```
22 to import, 0 to add, 0 to change, 0 to destroy
```

All sixteen existing VSIs, load balancer/listener/pool/members and SSH key must
remain no-op. Stop on any disk/VSI creation, replacement, deletion, detach,
boot/image/SSH/network change. Do not use `-target` or `create_before_destroy` to
work around a difference. Retain provider lock selections for review.

An authorized adoption later records existing cloud objects in the existing
remote state; it must not create them. This PR's tests did **not** apply imports,
write production state or operate on disks. They planned with a private local
backend, a read-only state snapshot and refreshed cloud GETs. The import blocks
are idempotent after adoption. Verify a no-change plan afterward.

## Node preparation

`worker_csi_metadata` exports node name, instance ID, InternalIP, region and zone.
`worker_data_storage` exports stable attachment IDs, filesystem UUIDs and expected
mount/runtime paths. After an authorized state update these can be obtained via
`terraform output -json <output-name>`; they contain no credentials. Before that,
reviewers can use planned outputs from the private import plan. Never send an
entire raw state file to node tooling.

Use `hack/prepare-vpc-csi-nodes.py` and `hack/vpc-csi-host-preflight.py` in
[kubernetes-sigs/provider-ibmcloud-test-infra](https://github.com/kubernetes-sigs/provider-ibmcloud-test-infra)
for guarded checks. Keep the node's existing mount UUID and containerd `--root`.
Do not run general cluster bootstrap/runtime installation on existing workers.
Fresh-node filesystem initialization or migration requires a separate reviewed
procedure; this adoption performs neither.
