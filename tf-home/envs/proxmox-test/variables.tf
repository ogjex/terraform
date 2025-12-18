
variable proxmox_api_url {
    type = string
}
variable proxmox_api_token_id {
    type = string
}
variable proxmox_api_token {
    type = string
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
    "prod-1" = { vm_id = 101, name = "prod-1", cores = 1, memory = 2048, }
  }
}

