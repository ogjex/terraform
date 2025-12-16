resource "proxmox_vm_qemu" "production" {
    vmid        = 200
    name        = "debian-production"
    target_node = "pve"

    clone       = "deb-13-clean"
    full_clone  = false
    bios        = "ovmf"
    agent       = 1
    scsihw      = "virtio-scsi-single"

    os_type     = "debian"
    cpu {
      type      = "x86-64-v2-AES"
      sockets   = 1
      cores     = 1
    }
    memory      = 2048

    disks {
      scsi {
        scsi0 {
          disk {
            size = "6G"
            storage = "local"
            format = "qcow2"
          }
        }
	    }
		}
}
