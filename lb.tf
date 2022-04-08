resource "oci_load_balancer" "CreateLoadBalancer" {
  provider       = oci.region2
  shape          = var.lb_shape
  compartment_id = oci_identity_compartment.compartment.id

  subnet_ids = [
    oci_core_subnet.public_subnet.id,
    #oci_core_subnet.CreatePublicSubnet2.id,
  ]

  display_name = var.lb_name
  is_private   = var.lb_is_private
}

resource "oci_load_balancer_backend_set" "CreateLoadBalancerBackendSet" {
  provider       = oci.region2
  name             = var.lb_be_name
  load_balancer_id = oci_load_balancer.CreateLoadBalancer.id
  policy           = var.lb_be_policy
  health_checker {
    port                = var.lb_be_health_checker_port
    protocol            = var.lb_be_health_checker_protocol
    response_body_regex = var.lb_be_health_checker_regex
    url_path            = var.lb_be_health_checker_urlpath
  }

  session_persistence_configuration {
    cookie_name      = var.lb_be_session_cookie
    disable_fallback = var.lb_be_session_fallback
  }
}

resource "oci_load_balancer_listener" "CreateListener" {
  provider       = oci.region2
  load_balancer_id         = oci_load_balancer.CreateLoadBalancer.id
  name                     = var.lb_listener_name
  default_backend_set_name = oci_load_balancer_backend_set.CreateLoadBalancerBackendSet.name

  #hostname_names           = [oci_load_balancer_hostname.test_hostname1.name, oci_load_balancer_hostname.test_hostname2.name]
  port     = var.lb_listener_port
  protocol = var.lb_listener_protocol

  #rule_set_names           = [oci_load_balancer_rule_set.test_rule_set.name]

  connection_configuration {
    idle_timeout_in_seconds = var.lb_listener_connection_configuration_idle_timeout
  }
}
