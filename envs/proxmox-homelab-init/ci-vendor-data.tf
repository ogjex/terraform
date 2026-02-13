resource "proxmox_virtual_environment_file" "tf_vendor_data_snippet" {
    content_type = "snippets"
    # define non-lvm datastore id
    datastore_id 	= var.pm_snippets_datastore_id
    node_name 		= var.pm_node_name
    source_raw {
data = <<EOF
#cloud-config
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
power_state:
  mode: reboot
  timeout: 30

runcmd:
  - systemctl restart sshd
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
  - echo "vendor-config done" > /tmp/vendor-cloud-config.done
  - reboot now

EOF

file_name = "tf_vendor_data_snippet.yaml"
   }
}


