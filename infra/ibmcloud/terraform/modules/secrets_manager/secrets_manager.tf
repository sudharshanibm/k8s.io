locals {
  secrets_manager_region   = "us-south"
  secrets_manager_name     = "${var.prefix}-ppc64le"
  iam_cred_secret_name     = "${var.prefix}-iam-secret"
  service_cred_secret_name = "${var.prefix}-svc-secret"
}

resource "ibm_resource_instance" "secrets_manager" {
  name              = local.secrets_manager_name
  resource_group_id = var.resource_group_id
  service           = "secrets-manager"
  plan              = "standard"
  location          = local.secrets_manager_region

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

resource "ibm_sm_iam_credentials_configuration" "sm_iam_credentials_configuration_instance" {
  instance_id = ibm_resource_instance.secrets_manager.guid
  region      = local.secrets_manager_region
  name        = "iam_config"
  api_key     = var.apikey
}

resource "ibm_sm_iam_credentials_secret" "sm_iam_credentials_secret" {
  depends_on    = [ibm_sm_iam_credentials_configuration.sm_iam_credentials_configuration_instance]
  instance_id   = ibm_resource_instance.secrets_manager.guid
  region        = local.secrets_manager_region
  name          = local.iam_cred_secret_name
  access_groups = [var.access_group_id]

  //Auto rotate secret after 1day = 24hrs, the minimum value is 1
  rotation {
    auto_rotate = true
    interval    = 1
    unit        = "day"
  }
  //The time-to-live (TTL) or lease duration of generated secret 93600seconds = 26hrs
  //The average job would run for ~2 hrs, hence we ensure secret remains alive post rotation period
  // rotation(24hrs)+job(2hrs) = 26hrs = 93600seconds
  ttl = "93600"
}

resource "ibm_iam_authorization_policy" "policy" {
  source_service_name         = "secrets-manager"
  source_resource_instance_id = ibm_resource_instance.secrets_manager.guid
  target_service_name         = "cloud-object-storage"
  target_resource_instance_id = var.cos_instance_guid
  roles                       = ["Key Manager"]
}

resource "ibm_sm_service_credentials_secret" "sm_service_credentials_secret" {
  depends_on  = [ibm_iam_authorization_policy.policy]
  instance_id = ibm_resource_instance.secrets_manager.guid
  region      = local.secrets_manager_region
  name        = local.service_cred_secret_name

  //Auto rotate secret after 1day = 24hrs, the minimum value is 1
  rotation {
    auto_rotate = true
    interval    = 1
    unit        = "day"
  }
  source_service {
    instance {
      crn = var.cos_instance_id
    }
    role {
      crn = "crn:v1:bluemix:public:iam::::serviceRole:Writer"
    }
    parameters = { "HMAC" : true }
  }
  //The time-to-live (TTL) or lease duration of generated secret 93600seconds = 26hrs
  //The average job would run for ~2 hrs, hence we ensure secret remains alive post rotation period
  // rotation(24hrs)+job(2hrs) = 26hrs = 93600seconds
  ttl = "93600"
}

# RSA key of size 4096 bits
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "ibm_sm_arbitrary_secret" "ssh_private_key" {
  name        = "powervs-ssh-private-key"
  instance_id = ibm_resource_instance.secrets_manager.guid
  region      = local.secrets_manager_region
  labels      = ["powervs-ssh-private-key"]
  payload     = tls_private_key.private_key.private_key_openssh
}

resource "ibm_sm_arbitrary_secret" "ssh_public_key" {
  name        = "powervs-ssh-public-key"
  instance_id = ibm_resource_instance.secrets_manager.guid
  region      = local.secrets_manager_region
  labels      = ["powervs-ssh-public-key"]
  payload     = tls_private_key.private_key.public_key_openssh
}
