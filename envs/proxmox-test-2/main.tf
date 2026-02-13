terraform {

  required_providers {
    proxmox = {
        source = "bpg/proxmox"
        version = "0.83.1"
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
    agent 		= false
    private_key 	= file(var.pm_ssh_private_key_path)
        username 		= var.pm_ssh_username
  }
}

### upload Cloud-init snippet file to the proxmox datastore
resource "proxmox_virtual_environment_file" "cloud_init_snippet" {
    content_type = "snippets"
    # define non-lvm datastore id
    datastore_id 	= var.pm_snippets_datastore_id
    node_name 		= var.pm_node_name
    source_raw {
	data = <<EOF
	    # cloud-config
      hostname: test-debian
	    timezone: UTC
	    chpasswd:
      expire: false

	    users:
        - name: ${var.ci_username}
        groups: sudo
        shell: /bin/bash
        sudo: ALL=(ALL) NOPASSWD:ALL
        lock_passwd: false
        plain_text_passwd: ${var.ci_password}
        ssh_authorized_keys:
            - ${trimspace(var.ci_ssh_public_key)}

	    # workaround for bpg terraform proxmox provider.
	    # we use ssh auth by login and password for Cloud-init by default for tty access
	    # and then disable password auth and provide ssh pub key in cloud-init-snippet
        write_files:
      - path: /etc/ssh/ssh_config.d/10-no-password.configure
      permissions: '0644'
      content: |
          # disable password authentication for all ssh connections
          PasswordAuthentication no

        package_update: true
        package_upgrade: true
        packages:
      - qemu-guest-agent
      - net-tools
      - curl
        runcmd:
      - systemctl restart sshd
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
      - reboot now
      
      EOF
      
		file_name = "cloud_init_snippet.yaml"
		}
}

### Create new vm via cloning from proxmox template and configure it using Cloud-init
resource "proxmox_virtual_environment_vm" "debian_vm" {
    name 	= "test-debian"
    node_name 	= var.pm_node_name
    
  clone {
    vm_id 		= 9000
    full 		= true
    datastore_id 	= var.pm_lvm_datastore_id
  }

  bios      = "ovmf"
  machine   = "q35"

  description     = "Managed by Terraform"
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
    enabled = true
  }
  
  # Resize disk
  disk {
      interface     = "scsi0"
      datastore_id  = var.pm_lvm_datastore_id
      size          = 10
      iothread      = true
      discard       = "on"
  }

  network_device {
    bridge  = "vmbr0"
    model   = "virtio"
  }
  
  # define Cloud-init settings
  initialization {
    user_data_file_id   = proxmox_virtual_environment_file.cloud_init_snippet.id

    # Define static ip address and default gateway
    ip_config {
      ipv4 {
        address = "192.168.1.230/2"
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
