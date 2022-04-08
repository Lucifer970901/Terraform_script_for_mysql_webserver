# vcn resources
resource "oci_core_vcn" "vcn1" {
  provider       = oci.region2
  cidr_block    = var.vcn_cidr_block
  dns_label      = "vcn"
  compartment_id = oci_identity_compartment.compartment.id
  display_name   = var.vcn_display_name
}

// A regional subnet will not specify an Availability Domain
resource "oci_core_subnet" "public_subnet" {
  provider          = oci.region2
  cidr_block        = var.pub_subnet_cidr_block
  display_name      = "MASHR-Public-Subnet"
  dns_label         = "PublicSubnet"
  compartment_id    = oci_identity_compartment.compartment.id
  vcn_id            = oci_core_vcn.vcn1.id
  security_list_ids = [oci_core_security_list.public_security_list.id]
  route_table_id    = oci_core_route_table.public_route_table.id
  dhcp_options_id   = oci_core_vcn.vcn1.default_dhcp_options_id
}

resource "oci_core_internet_gateway" "test_internet_gateway" {
  provider       = oci.region2
  compartment_id = oci_identity_compartment.compartment.id
  display_name   = "MASHR-IGW"
  vcn_id         = oci_core_vcn.vcn1.id
}


resource "oci_core_route_table" "public_route_table" {
  provider       = oci.region2
  display_name   = "MASHR-Public-Subnet-RT"
  vcn_id         = oci_core_vcn.vcn1.id
  compartment_id = oci_identity_compartment.compartment.id
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.test_internet_gateway.id
  }
}

resource "oci_core_security_list" "public_security_list" {
  provider       = oci.region2
  display_name   = "MASHR-Public-Subnet-SL"
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id         = oci_core_vcn.vcn1.id

  // allow outbound tcp traffic on all ports
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "6"
  }

  // allow inbound ssh traffic
  ingress_security_rules {
    protocol  = "6" // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  // allow inbound ssh traffic
  ingress_security_rules {
    protocol  = "6" // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 80
      max = 80
    }
  }
  // allow inbound ssh traffic
  ingress_security_rules {
    protocol  = "6" // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 443
      max = 443
    }
  }

  // allow inbound ssh traffic
  ingress_security_rules {
    protocol  = "6" // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 9000
      max = 9000
    }
  }

  // allow inbound ssh traffic
  ingress_security_rules {
    protocol  = "6" // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 1337
      max = 1337
    }
  }

  // allow inbound ssh traffic
  ingress_security_rules {
    protocol  = "6" // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 3000
      max = 3000
    }
  }

  // allow inbound icmp traffic of a specific type
  ingress_security_rules {
    protocol  = 1
    source    = "0.0.0.0/0"
    stateless = true

    icmp_options {
      type = 3
      code = 4
    }
  }
}

// An AD based subnet will supply an Availability Domain
resource "oci_core_subnet" "private_subnet" {
  provider       = oci.region2
  availability_domain = data.oci_identity_availability_domain.ad.name
  cidr_block          = var.pri_subnet_cidr_block
  display_name        = "MASHR-Private-Subnet"
  dns_label           = "PrivateSubnet"
  compartment_id      = oci_identity_compartment.compartment.id
  vcn_id              = oci_core_vcn.vcn1.id
  security_list_ids   = [oci_core_security_list.private_security_list.id]
  route_table_id      = oci_core_route_table.private_route_table.id
  dhcp_options_id     = oci_core_vcn.vcn1.default_dhcp_options_id
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_nat_gateway" "nat_gateway" {
  provider       = oci.region2
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id         = oci_core_vcn.vcn1.id
  display_name   = "nat_gateway"
}


resource "oci_core_route_table" "private_route_table" {
  provider       = oci.region2
  compartment_id = oci_identity_compartment.compartment.id
  vcn_id         = oci_core_vcn.vcn1.id
  display_name   = "MASHR-Private-Subnet-RT"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat_gateway.id
  }
}

resource "oci_core_security_list" "private_security_list" {
  provider       = oci.region2
  display_name   = "MASHR-Private-Subnet-SL"
  vcn_id         = oci_core_vcn.vcn1.id
  compartment_id = oci_identity_compartment.compartment.id

  // allow outbound tcp traffic on all ports
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "6"
  }

  // allow inbound ssh traffic
  ingress_security_rules {
    protocol  = "6" // tcp
    source    = var.pri_subnet_cidr_block
    stateless = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  // allow inbound ssh traffic
  ingress_security_rules {
    protocol  = "6" // tcp
    source    = var.pri_subnet_cidr_block
    stateless = false

    tcp_options {
      min = 80
      max = 80
    }
  }
  // allow inbound ssh traffic
  ingress_security_rules {
    protocol  = "6" // tcp
    source    = var.pri_subnet_cidr_block
    stateless = false

    tcp_options {
      min = 443
      max = 443
    }
  }

  // allow inbound ssh traffic
  ingress_security_rules {
    protocol  = "6" // tcp
    source    = var.pri_subnet_cidr_block
    stateless = false

    tcp_options {
      min = 9000
      max = 9000
    }
  }

  // allow inbound ssh traffic
  ingress_security_rules {
    protocol  = "6" // tcp
    source    = var.pri_subnet_cidr_block
    stateless = false

    tcp_options {
      min = 1337
      max = 1337
    }
  }

  // allow inbound ssh traffic
  ingress_security_rules {
    protocol  = "6" // tcp
    source    = var.pri_subnet_cidr_block
    stateless = false

    tcp_options {
      min = 3306
      max = 3306
    }
  }

// allow inbound ssh traffic
  ingress_security_rules {
    protocol  = "6" // tcp
    source    = var.pri_subnet_cidr_block
    stateless = false

    tcp_options {
      min = 33060
      max = 33060
    }
  }


  // allow inbound icmp traffic of a specific type
  ingress_security_rules {
    protocol  = 1
    source    = var.pri_subnet_cidr_block
    stateless = true

    icmp_options {
        type = 3
        code = 4
    }
  }
}
