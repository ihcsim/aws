variable "region" {
  default = "us-west-2"
}

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
