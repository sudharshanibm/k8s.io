# IBM s390x VPC CSI identity

This independent Terraform root codifies the production identity already created
on 10 November 2026. Its backend is
`k8s-z-infra-tf-states/k8s-s390x-csi-identity/terraform.tfstate`. Keep the existing
resource addresses/backend: do not import/recreate this identity in the build,
conformance or shared infrastructure states.

It manages one dedicated access group, its RG-scoped VPC Editor/Writer policy,
RG Viewer policy, and a managed IAM credential secret. This is resource-group
scoping, not a custom volume-only IAM role. The expected account is checked
against the resource group's account before identity creation.

The existing Secrets Manager IAM engine and shared secret-rotator remain owned by
the shared infrastructure. The secret uses `rotate:true`, a 12-hour TTL and
`reuse_api_key=true`; the existing two-hour rotator renews it. Do not configure a
second engine/rotator or rotate unrelated identities from this root.

## Inputs and outputs

Requires Terraform >=1.11 and IBM provider ~>1.82.0 (validated with 1.82.1).
Copy the non-secret production inputs in `terraform.tfvars.example` into a
private var file. Supply `TF_VAR_ibmcloud_api_key` and COS HMAC credentials through
your normal protected environment. Never commit API keys, plans, state or private
SSH material. A Terraform state/JSON plan can contain secret payloads even if the
normal CLI display marks them sensitive.

Outputs identify the access group, RG, secret UUID and a credential-free
ExternalSecret manifest. The production secret is
`352757d9-a239-aa3c-a70a-4d0c583f0244` in SM instance
`0664d47c-fe42-423f-930d-69570443cd15`. The active cluster ExternalSecret lives in
`kubernetes/ibm-s390x/kube-system/vpc-csi-secret.yaml`; it consumes the existing
`secretstore-ibm-k8s` and renders the driver's `slclient.toml`.

## Existing production identity

Review an ordinary plan against the existing backend and exact production inputs
before any separately authorized apply. Expected managed-resource result is
**no changes**, not four new resources. Do not proceed if an identity/secret
replacement, shared IAM-engine change or unexpected rotation is proposed.

For safe offline validation, initialize providers with `-backend=false`. For
state comparison, use a private scratch copy with a local backend and a securely
obtained state snapshot; never initialize a different backend over the source
root or commit that scratch copy. The PR validation used this isolation with a
fully refreshed plan, and made no production state/resource changes.

See the [CSI deployment](../../../../kubernetes/ibm-s390x/vpc-csi/README.md) for
rotation reload and GitOps ownership. Monitoring already runs in agent mode and
is not changed by this root.
