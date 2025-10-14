# variables.pkr.hcl — declare inputs only, no hard-coded values

# ISO settings
variable "iso_url" {
  type = string
}

variable "iso_checksum" {
  type = string
}

# SSH build account
# variable "ssh_username" {
#   type = string
# }

# variable "ssh_private_key_file" {
#   type      = string
#   sensitive = true
# }

variable "ssh_public_key" {
  type      = string
  sensitive = true
}

# General VM settings
variable "cpu_count" {
  type = number
}

variable "ram_mb" {
  type = number
}

variable "disk_size_mb" {
  type = number
}

variable "vm_name" {
  type = string
}

variable "updates_policy" {
  type = string
}

variable "firewall_enabled" {
  type = string
}

variable "selinux_policy" {
  type = string
}