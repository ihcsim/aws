resource "aws_security_group" "nodes" {
  name = "${var.project}-nodes"
  description = "Security group for the nodes"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 9903
    to_port = 9903
    protocol = "tcp"
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = ["${aws_vpc.main.default_security_group_id}"]
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }

  tags {
    Name = "${var.project}-nodes"
    Owner = "${var.author}"
    Project = "${var.project}"
  }
}
