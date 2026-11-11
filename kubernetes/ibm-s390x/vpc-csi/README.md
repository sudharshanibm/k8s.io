# IBM s390x VPC Block CSI

This component adopts the existing production deployment into the s390x
kube-system application. It is included by `../kube-system/kustomization.yaml`;
merging that inclusion enables Argo reconciliation. Review the generated diff
before merge/sync. The shared ApplicationSet automatically self-heals/prunes.

## Qualified image and placement

The driver uses upstream manifest commit
`3fff6454169aca35961993b49fae98ade600ad24`, containing merged [#278](https://github.com/kubernetes-sigs/ibm-vpc-block-csi-driver/pull/278)
and [#280](https://github.com/kubernetes-sigs/ibm-vpc-block-csi-driver/pull/280).
The immutable driver index is
`gcr.io/k8s-staging-cloud-provider-ibm/ibm-vpc-block-csi-driver@sha256:4918b0d2d5c9ef9d7783ed397ba9828f2eb31dd6363ab42ca3730b5569899e88`
([successful upstream publish](https://prow.k8s.io/view/gs/kubernetes-ci-logs/logs/post-ibm-vpc-block-csi-driver-push-images/2120048843029483520)).
This is an upstream staging image, not a promoted release. Its index/image configs
were checked for amd64, arm64, ppc64le and s390x; runtime validation here is s390x.
A later approved release/promotion can change the image in a separate PR. Personal
Quay/GHCR validation images are not used.

One controller Deployment serves the cluster. The node DaemonSet runs on all ten
opted-in s390x workers (`storage.ibmcloud.k8s.io/vpc-csi-ready=true`), not control
planes. Adding metadata/opt-in for new workers requires the provider's identity
and host preflight; this manifest does not infer cloud instance IDs or alter
providerID. Snapshot support is excluded: no snapshot CRDs/controller are added.
Keep the existing sidecars, kubelet/device mounts, selectors and rollout settings.

## Credentials and GitOps ownership

`../kube-system/vpc-csi-secret.yaml` references the existing dedicated managed IAM
credential through `secretstore-ibm-k8s`. External Secrets owns
`kube-system/storage-secret-store` and renders `slclient.toml`; the upstream empty
Secret is removed from the Kustomization. The independent identity Terraform root
keeps the same production state/resource addresses and reuses the existing IAM
engine/shared secret rotator. No API key belongs in Git.

The five-minute credential reload CronJob hashes only Secret data and patches
only the two named workloads when it changes. Its RBAC can read only that Secret
and get/patch only those workloads. It does not rotate credentials. The s390x-only
ApplicationSet template patch ignores only its credential-hash annotation and
respects that ignore during sync, avoiding a self-heal/reload loop. Other cluster
applications receive an empty patch.

Deployment/DaemonSet/CSIDriver/StorageClass and ExternalSecret have `Prune=confirm`.
Removing this component or its secret needs an explicit pruning decision. Never
use a path-removing revert as the default CSI rollback; retain the component and
restore the previously qualified configuration. Existing canary StorageClass and
proof namespaces/PVCs/PVs remain outside this application's adoption inventory.

## StorageClass

`ibmc-vpc-block-retain-general-purpose` is non-default, ext4, hourly, Retain,
WaitForFirstConsumer, and expansion-enabled. Consumers must select it explicitly.
A Pending PVC before a consumer is scheduled is expected with delayed binding.
Deleting a PVC retains its cloud volume; disposal is a separate owner decision.
These general-purpose application disks are independent of the static 10iops-tier
containerd disks on workers. No existing storage profile/default is changed.

Monitoring is already configured as a Prometheus agent by [#10126](https://github.com/kubernetes/k8s.io/pull/10126),
using emptyDir and remote-write to Mimir. This change does not switch monitoring
to a PVC, change its resources or reintroduce the old full-Prometheus draft.

## Validation and adoption

Render without cluster writes:

```sh
kubectl kustomize kubernetes/ibm-s390x/kube-system > /private/path/s390x-kube-system.yaml
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s kubernetes/ibm-s390x/vpc-csi/tests -v
```

Compare declared Pod templates and generated reload ConfigMap against live GETs;
ignore Kubernetes defaults and the one dynamically owned hash annotation. The
initial adoption should not request a workload rollout or replace selectors.
Review the generated s390x Argo application and ownership/pruning policy before
activation. Check ExternalSecret Ready, controller Ready, all ten node agents and
CSI node registrations, then inspect retained PVC evidence. Do not create/delete
new production tests or force credential rotation as part of adoption.

See [VALIDATION.md](VALIDATION.md) for the read-only premerge results and limits.
