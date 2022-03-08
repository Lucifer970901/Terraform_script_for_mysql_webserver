resource "oci_core_instance" "public_instance" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = oci_identity_compartment.compartment.id
  display_name = var.instance_display_name
  shape = var.instance_shape

  shape_config {
  ocpus = var.instance_ocpus
  baseline_ocpu_utilization = var.baseline_ocpu_utilization
  memory_in_gbs = var.instance_shape_config_memory_in_gbs
}

  create_vnic_details {
    subnet_id        = oci_core_subnet.public_subnet.id
    display_name     = "Primaryvnic"
    assign_public_ip = true
    #private_ip = var.instance_private_ip
    hostname_label   = "MASHR-APPinstance"
  }

  source_details {
    source_type = "image"
    source_id = var.flex_instance_image_ocid[var.region]
    boot_volume_size_in_gbs = "50"

  }
  timeouts {
      create = "60m"
    }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key)
    user_data  =base64encode(var.user-data)
//#base64encode(file("./userdata/bootstrap"))
  }

}

resource "oci_core_volume" "public_instance"{
availability_domain = data.oci_identity_availability_domain.ad.name
compartment_id = oci_identity_compartment.compartment.id
display_name = "MASHR-APP-volume"
size_in_gbs = "50"
}

resource "oci_core_volume_attachment" "public_instance" {
  count           = "1"
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.public_instance.id
  volume_id       = oci_core_volume.public_instance.id
  use_chap        = true
}
