resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr}"
  assign_generated_ipv6_cidr_block = "${var.enabled_ipv6}"

  tags {
    Name = "${var.project}"
    Owner = "${var.author}"
  }
}
