variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "region" {}

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
