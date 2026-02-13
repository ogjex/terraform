terraform {
  required_version = ">=1.14.0"
  required_providers {
    proxmox = {
        source = "bpg/proxmox"
        version = "0.95.0"
    }
  }
}

### configure bpg proxmox provider
provider "proxmox" {
    endpoint 	= var.pm_api_url
    api_token 	= var.pm_api_token
    insecure 	= var.pm_tls_insecure
    
    ### Cloud-init snippets uploaded via ssh connection to proxmox host
  ssh {
    agent 		= true
    private_key 	= file(var.pm_ssh_private_key_path)
        username 		= var.pm_ssh_username
  }
}

### Create new vm via cloning from proxmox template and configure it using Cloud-init
resource "proxmox_virtual_environment_vm" "debian_vm" {
    node_name 	= var.pm_node_name
    name 	      = "test-debian"
    description = "Managed by Terraform"
    tags        = ["terraform", "debian"]
    
  clone {
    vm_id 		= 9100
    full 		= true
    datastore_id 	= var.pm_lvm_datastore_id
  }

  bios      = "ovmf"
  machine   = "q35"

  started         = true
  stop_on_destroy = true

  cpu {
    cores = 2
    type  = "host"
  }
  memory {
    dedicated   = 2048
  }

  agent {
    enabled = false
  }

    # Resize disk
  disk {
      interface     = "scsi0"
      datastore_id  = var.pm_lvm_datastore_id
      size          = 10
      iothread      = false
      discard       = "on"
  }

  network_device {
    bridge  = "vmbr0"
    model   = "virtio"
  }

  # define Cloud-init settings
  initialization {
    user_data_file_id   = proxmox_virtual_environment_file.tf_user_data_snippet.id
    vendor_data_file_id = proxmox_virtual_environment_file.tf_vendor_data_snippet.id
    # Define static ip address and default gateway
    ip_config {
      ipv4 {
        address = "192.168.1.230/24"
        gateway = "192.168.1.1"
      }
    }

    user_account {
    # Workaround for bpg Terraform proxmox provider. 
    # We use ssh auth by login and password for cloud-init by default for tty access from proxmox web console
    # and then disable password auth and provide ssh pub key in cloud-init-snippet 
      username = var.ci_username
      password = var.ci_password
    }
    
    dns {
      servers = ["1.1.1.1", "8.8.8.8"]
    }
  }
}

### Create new vm via cloning from proxmox template and configure it using Cloud-init
resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
    node_name 	= var.pm_node_name
    name 	      = "test-ubuntu"
    description = "Managed by Terraform"
    tags        = ["terraform", "ubuntu"]
    
  clone {
    vm_id 		= 9200
    full 		= true
    datastore_id 	= var.pm_lvm_datastore_id
  }

  bios      = "ovmf"
  machine   = "q35"

  started         = true
  stop_on_destroy = true

  cpu {
    cores = 2
    type  = "host"
  }
  memory {
    dedicated   = 2048
  }

  agent {
    enabled = false
  }

    # Resize disk
  disk {
      interface     = "scsi0"
      datastore_id  = var.pm_lvm_datastore_id
      size          = 10
      iothread      = false
      discard       = "on"
  }

  network_device {
    bridge  = "vmbr0"
    model   = "virtio"
  }

  # define Cloud-init settings
  initialization {
    user_data_file_id   = proxmox_virtual_environment_file.tf_user_data_snippet.id
    vendor_data_file_id = proxmox_virtual_environment_file.tf_vendor_data_snippet.id
    # Define static ip address and default gateway
    ip_config {
      ipv4 {
        address = "192.168.1.231/24"
        gateway = "192.168.1.1"
      }
    }

    user_account {
    # Workaround for bpg Terraform proxmox provider. 
    # We use ssh auth by login and password for cloud-init by default for tty access from proxmox web console
    # and then disable password auth and provide ssh pub key in cloud-init-snippet 
      username = var.ci_username
      password = var.ci_password
    }
    
    dns {
      servers = ["1.1.1.1", "8.8.8.8"]
    }
  }
}
