resource "oci_mysql_mysql_backup" "test_mysql_backup" {
  db_system_id = oci_mysql_mysql_db_system.test_mysql_backup_db_system.id
}

resource "oci_mysql_mysql_db_system" "test_mysql_backup_db_system" {
  #Required
  admin_password      = "Oracle123#"
  admin_username      = "adminUser"
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = oci_identity_compartment.compartment.id
  configuration_id    = data.oci_mysql_mysql_configurations.test_mysql_configurations.configurations[0].id
  shape_name          = "MySQL.VM.Standard.E3.1.8GB"
  subnet_id           = oci_core_subnet.private_subnet.id
  

  #Optional
  data_storage_size_in_gb = "50"
}

resource "oci_mysql_mysql_db_system" "test_mysql_db_system" {
  #Required
  compartment_id      = oci_identity_compartment.compartment.id
  admin_password      = "Oracle123#"
  admin_username      = "adminUser"
  availability_domain = data.oci_identity_availability_domain.ad.name
  configuration_id    = data.oci_mysql_mysql_configurations.test_mysql_configurations.configurations[0].id
  shape_name = "MySQL.VM.Standard.E3.1.8GB"
  subnet_id           = oci_core_subnet.private_subnet.id

  #Optional
  backup_policy {
    is_enabled        = "false"
    retention_in_days = "10"
    window_start_time = "01:00-00:00"
  }

  display_name   = var.mysql_display_name
  fault_domain   = "FAULT-DOMAIN-1"
  hostname_label = "hostnameLabel"
  ip_address     = var.mysql_ip_address

  maintenance {
    window_start_time = "sun 01:00"
  }

  port          = "3306"
  port_x        = "33306"

  # Creating DB System using a backup
  source {
    backup_id   = oci_mysql_mysql_backup.test_mysql_backup.id
    source_type = "BACKUP"
  #  availability_domain = data.oci_identity_availability_domain.ad[0].name
  }
}
