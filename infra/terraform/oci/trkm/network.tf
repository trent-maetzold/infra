# The tenancy's network. Hosts buy into it rather than each making their own,
# so a second instance is just an instance. Everything here is a thing a host
# stack could otherwise duplicate by accident.
resource "oci_core_vcn" "trkm" {
  compartment_id = var.compartment_id
  display_name   = "trkm"
  cidr_block     = "10.0.0.0/16"
  dns_label      = "trkm"
}

resource "oci_core_internet_gateway" "trkm_internet_gateway" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.trkm.id
  display_name   = "trkm-internet-gateway"
}

resource "oci_core_route_table" "trkm_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.trkm.id
  display_name   = "trkm-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.trkm_internet_gateway.id
  }
}

resource "oci_core_security_list" "trkm_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.trkm.id
  display_name   = "trkm-security-list"

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "ssh"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "http and https"
    tcp_options {
      min = 80
      max = 443
    }
  }

  # Without this, packets large enough to need fragmenting are dropped instead:
  # TCP connections hang right after the handshake.
  ingress_security_rules {
    protocol    = "1"
    source      = "0.0.0.0/0"
    description = "path mtu discovery"
    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "all"
  }
}

resource "oci_core_subnet" "net" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.trkm.id
  display_name   = "net"
  cidr_block     = "10.0.0.0/24"
  dns_label      = "net"

  route_table_id    = oci_core_route_table.trkm_route_table.id
  security_list_ids = [oci_core_security_list.trkm_security_list.id]
}
