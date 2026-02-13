variable "pm_api_url" {
    type 	= string
    description = "Proxmox API URL (https://192.168.1.220/8006/api2/json)" 
}

variable "pm_api_token" {
    type 	      = string
    sensitive 	= true
    description = "Proxmox API token" 
}

variable "pm_ssh_username" {
    type 	      = string
    default     = "root" 
}

variable "pm_ssh_private_key_path" {
    type 	      = string
    default     = "~/.ssh/id_ed25519"
  }

variable "pm_tls_insecure" {
    type 	      = bool
    default     = true
}

variable "pm_node_name" {
    type 	      = string
    default     = "pve"
}

variable "pm_lvm_datastore_id" {
    type 	      = string
    default     = "local-lvm"
}

variable "pm_snippets_datastore_id" {
    type 	      = string
    default     = "local"
}

variable "ci_username" {
    type 	      = string
    description = "Cloud-init default user"
}

variable "ci_password" {
    type 	      = string
    sensitive   = true
}

variable "ci_ssh_public_key" {
    type 	      = string
    description = "SSH public key"
}



