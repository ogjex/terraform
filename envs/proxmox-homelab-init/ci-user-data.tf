resource "proxmox_virtual_environment_file" "tf_user_data_snippet" {
    content_type = "snippets"
    # define non-lvm datastore id
    datastore_id 	= var.pm_snippets_datastore_id
    node_name 		= var.pm_node_name
    source_raw {
data = <<EOF
#cloud-config
hostname: test-debian
timezone: Europe/Copenhagen
locale: da-DK
keyboard:
  layout: dk-latin1
  variant: nodeadkeys
chpasswd:
  expire: false
users:
  - default
  - name: ${var.ci_username}
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    plain_text_passwd: ${var.ci_password}
    ssh_authorized_keys:
      - ${trimspace(var.ci_ssh_public_key)}
runcmd:
  - echo "user-config done" > /tmp/user-cloud-config.done
 
EOF

file_name = "tf_user_data_snippet.yaml"
   }
}


