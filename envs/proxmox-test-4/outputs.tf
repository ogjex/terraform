# bgp-example/outputs.tf
output "public_ipv4" {
  description = "Instance Public IPv4 Address"
  value       = flatten(proxmox_virtual_environment_vm.vm.ipv4_addresses[1])
}

