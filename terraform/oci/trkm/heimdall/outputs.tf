# Both addresses are OCI's choice and change when the instance is rebuilt. Read
# them with `just oci-output` and point the DNS record at the new one.
output "heimdall_ip" {
  value = oci_core_instance.heimdall.public_ip
}

output "heimdall_private_ip" {
  value = oci_core_instance.heimdall.private_ip
}
