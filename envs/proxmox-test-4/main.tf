# bgp-example/main.tf
terraform {
  required_version = ">=1.5.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.53.1"
    }
  }
}

provider "proxmox" {
  endpoint  = var.pve_api_url
  api_token = "${var.pve_token_id}=${var.pve_token_secret}"
  insecure  = true
}

resource "proxmox_virtual_environment_vm" "vm" {
  node_name   = "pve"
  vm_id       = 100
  name        = "vm-example"
  description = "Managed by Terraform"
  tags        = ["terraform", "ubuntu"]
  bios        = var.bios

  # clone from the Ubuntu 24.04 template we created earlier
  clone {
    vm_id = 9024
    full  = true
  }

  # keep the first disk as boot disk
  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 8
    file_format  = "raw"
    cache        = "writeback"
    iothread     = false
    ssd          = true
    discard      = "on"
  }

  # create an EFI disk when the bios is set to ovmf
  dynamic "efi_disk" {
    for_each = (var.bios == "ovmf" ? [1] : [])
    content {
      datastore_id      = "local-lvm"
      file_format       = "raw"
      type              = "4m"
      pre_enrolled_keys = true
    }
  }

  network_device {
    bridge  = "vmbr0"
    vlan_id = "1"
  }

  # cloud-init config
  initialization {
    interface           = "ide2"
    type                = "nocloud"
    vendor_data_file_id = "local:snippets/vendor-data.yaml"

    # add SSH key to cloud-init default user
    user_account {
      keys     = [file("${var.ci_ssh_key}")]
    }

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  # cloud-init SSH keys will cause a forced replacement, this is expected
  # behavior see https://github.com/bpg/terraform-provider-proxmox/issues/373
  lifecycle {
    ignore_changes = [initialization["user_account"], ]
  }
}

