# Read by the host stacks, so the subnet is created exactly once.
output "subnet_id" {
  value = oci_core_subnet.net.id
}
