variable "region" {}
variable "keypair_name" {}

variable "project" {
  default = "isim-ao-training"
}

variable "author" {
  default = "isim"
}

variable "vpc_cidr" {
  default = "10.50.0.0/16"
}

variable "enabled_ipv6" {
  default = "true"
}

variable "subnets_az" {
  default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "subnets_public_cidr" {
  default = {
    "us-west-2a" = "10.50.10.0/24"
    "us-west-2b" = "10.50.20.0/24"
    "us-west-2c" = "10.50.30.0/24"
  }
}

variable "subnets_private_cidr" {
  default = {
    "us-west-2a" = "10.50.90.0/24"
    "us-west-2b" = "10.50.100.0/24"
    "us-west-2c" = "10.50.200.0/24"
  }
}

variable "api_server_asg_size" {
  default = {
    "min" = 1
    "max" = 5
  }
}

variable "instance_type" {
  default = {
    "api_server" = "t2.micro"
    "game" = "t2.micro"
    "analytics" = "t2.micro"
  }
}

variable "ubuntu_ami" {
  default = "ami-79873901"
}

variable "metrics_alarm_api_server_cpu_thresholds" {
  default = {
    "upper" = "70"
    "lower" = "50"
  }
}

variable "metrics_alarm_api_server_network_thresholds" {
  default = {
    "upper" = "1000000"
    "lower" = "500000"
  }
}
