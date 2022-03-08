# define provider configuration
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = 1
}

#variables of default components
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}

# variables for vcn networking components
variable "vcn_cidr_block"{
#default = "10.1.0.0/16"
}

variable "vcn_display_name"{
#default = "mashr_vcn"
}

variable "pub_subnet_cidr_block"{
#default = "10.1.1.0/24"
 }

variable "pri_subnet_cidr_block"{
#default = "10.1.2.0/24"
}


# variables for instance components
variable "instance_display_name"{
#default = "MASHR_APP"
}
variable "instance_shape" {
  default = "VM.Standard.E3.Flex"
}

variable "instance_ocpus" {
  default = 2
}

variable "instance_shape_config_memory_in_gbs" {
  default = 16
}

variable "flex_instance_image_ocid" {
  type = map(string)
  default = {
    us-phoenix-1 = "ocid1.image.oc1.phx.aaaaaaaa6hooptnlbfwr5lwemqjbu3uqidntrlhnt45yihfj222zahe7p3wq"
    us-ashburn-1 = "ocid1.image.oc1.iad.aaaaaaaa6tp7lhyrcokdtf7vrbmxyp2pctgg4uxvt4jz4vc47qoc2ec4anha"
    ap-sydney-1 = "ocid1.image.oc1.ap-sydney-1.aaaaaaaarq27mn2xvjnyzcghzfcvyez7h5p4arxawy6td5iggj3nxwcmh24a"
    ap-melbourne-1 = "ocid1.image.oc1.ap-melbourne-1.aaaaaaaajkkoyr6fzbljbgnzqdi2mxj4clxrlhcapptot6rrpq744a6p3kjq"
  }
}

variable "ssh_public_key" {
default = "~/.ssh/id_rsa.pub"
}

variable "ssh_private_key" {
default = "~/.ssh/id_rsa"
}

#variable "instance_private_ip"{
#default = "10.1.1.168"
#}

#mysql components
variable "mysql_ip_address"{
#default = "10.1.2.212"
}

variable"mysql_display_name"{
#default ="MASHR_MDS"
}

data "oci_mysql_mysql_configurations" "test_mysql_configurations" {
  compartment_id = var.compartment_ocid

  #Optional
  state        = "ACTIVE"
  shape_name   = "MySQL.VM.Standard.E3.1.8GB"
}

data "oci_mysql_shapes" "test_shapes" {
  compartment_id = var.compartment_ocid
  
}

variable "baseline_ocpu_utilization"{
default = "BASELINE_1_2"
}

variable "memory_in_gbs" {
default = "50"
}
variable "ocpus"{
default = "2"
}

variable "user-data" {
  default = <<EOF
#!/bin/bash -x
echo '################### webserver userdata begins #####################'
touch ~opc/userdata.`date +%s`.start
# echo '########## yum update all ###############'
sudo yum update -y
echo '########## basic webserver ##############'
sudo yum install -y httpd
sudo systemctl enable  httpd.service
sudo systemctl start  httpd.service
echo '<html><head></head><body><pre><code>' > /var/www/html/index.html
hostname >> /var/www/html/index.html
echo '' >> /var/www/html/index.html
cat /etc/os-release >> /var/www/html/index.html
echo '</code></pre></body></html>' >> /var/www/html/index.html
sudo firewall-cmd --zone=public --permanent --add-service=http
sudo systemctl disable  firewalld
sudo systemctl stop  firewalld
sudo firewall-cmd --reload

sudo yum install -y php
sudo systemctl restart httpd
#sudo vi /var/www/html/info.php
curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -
sudo yum install -y nodejs
npm install -g
sudo npm install -g create-react-app

touch ~opc/userdata.`date +%s`.finish
echo '################### webserver userdata ends #######################'
EOF
} // User data to install httpd server and disable firewalld


// LOAD BALANCER VARIABLES

variable "lb_shape" {
  default = "100Mbps"
}

variable "lb_name" {
  default = "Mashr_LB"
}

variable "lb_is_private" {
  default = false
}

variable "lb_be_name" {
  default = "Mashr_LBBE1"
}

variable "lb_be_policy" {
  default = "ROUND_ROBIN"
}

variable "lb_be_health_checker_port" {
  default = "80"
}

variable "lb_be_health_checker_protocol" {
  default = "HTTP"
}

variable "lb_be_health_checker_regex" {
  default = ".*"
}

variable "lb_be_health_checker_urlpath" {
  default = "/index.html"
}

variable "lb_be_session_cookie" {
  default = "lb-session1"
}

variable "lb_be_session_fallback" {
  default = true
}

variable "lb_listener_name" {
  default = "MyHTTPListener"
}

variable "lb_listener_port" {
  default = 80
}

variable "lb_listener_protocol" {
  default = "HTTP"
}

variable "lb_listener_connection_configuration_idle_timeout" {
  default = "400"
}
