variable "ibmcloud_api_key" {
  type = string
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key file"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "instance_image_id" {
  description = "Image ID used for all instances"
  type        = string
  default     = "r010-1476c687-824d-4b10-b604-7538defb3c73"
}

variable "instance_profile" {
  description = "Profile used for all instances"
  type        = string
  default     = "bz2-2x8"
}

variable "api_port" {
  description = "Port for Kubernetes API"
  type        = number
  default     = 6443
}
