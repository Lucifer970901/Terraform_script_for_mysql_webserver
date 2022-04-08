#resource block for compartment

resource "oci_identity_compartment" "compartment" {
  provider       = oci.home
  compartment_id = var.compartment_ocid
  description    = "create a comparment within your oci compartment"
  name           = "Mashr_lab_compartment"
  region         = var.region1
}

resource "time_sleep" "wait_60_seconds" {
  depends_on = [oci_identity_compartment.compartment]

  create_duration = "60s"
}
