#outputs

#new compartment created 
output "compartment_id"{
 value = oci_identity_compartment.compartment.id
}

#VCN
output "vcn_id" {
  value = oci_core_vcn.vcn1.id
}
output "web_server_id"{
value = oci_core_instance.public_instance.id
}
output "database_id"{
value = oci_mysql_mysql_db_system.test_mysql_db_system.id
}

# output "instance_private_ips" {
#  value = [oci_core_instance.test_instance.*.private_ip]
# }

output "instance_public_ips" {
  value = [oci_core_instance.public_instance.*.public_ip]
}

# Output the boot volume IDs of the instance
output "boot_volume_ids" {
  value = [oci_core_instance.public_instance.*.boot_volume_id]
}

output "lb_public_ip" {
  value = [oci_load_balancer.CreateLoadBalancer.ip_address_details]
}
