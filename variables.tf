variable "ssh_key_public" {
  default     = "~/.ssh/id_rsa.pub"
  description = "Path to the SSH public key for accessing cloud instances."
}

variable "ssh_key_private" {
  default     = "~/.ssh/id_rsa"
  description = "Path to the SSH private key for accessing cloud instances."
}

variable "prefix" {
  default     = "terraform"
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  default     = "eastus"
  description = "The Azure Region in which all resources in this example should be created."
}

variable "admin_user" {
  default     = "stphnsmpsn"
  description = "The admin username on the newly created VM"
}
