variable proxmox_api_url {
    type = string
}
variable proxmox_api_token_id {
    type = string
    sensitive = true
}
variable proxmox_api_token {
    type = string
    sensitive = true
}
variable ci_user {
    type = string
    sensitive = true
}
variable ci_password {
    type = string
    sensitive = true
}
variable ssh_keys {
    type = string
    sensitive = true
}
 
variable vm_configs {
    type = map(object({
        vm_id         = number
        name          = string
        memory        = number
        vm_state      = string
        onboot        = bool
        startup       = string
        ipconfig      = string
        ciuser        = string
        cipassword    = string
        sshkeys       = string
        cores         = number
        bridge        = string
        network_tag   = number 
      }))
      default = {
        "vm-1" = {
          vm_id         = 200
          name          = "test-vm1"
          memory        = 1024
          vm_state      = "stopped"
          onboot        = true
          startup       = "order=2"
          ipconfig      = "ip=192.168.1.204/24,gw=192.168.1.0"
          ciuser        = var.ci_user
          cipassword    = var.ci_password
          sshkeys       = var.ssh_keys
          cores         = 1
          bridge        = "vmbr0"
          network_tag   = 0
        }
      }
}

