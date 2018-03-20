resource "aws_security_group" "api_server" {
  name = "${var.project}-api-server"
  description = "Security group for the API Servers"
  vpc_id = "${aws_vpc.main.id}"

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
    Name = "${var.project}-api-server"
    Owner = "${var.author}"
    Project = "${var.project}"
  }
}

resource "aws_security_group" "ssh" {
  name = "${var.project}-ssh"
  description = "Security group for the SSH access"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    to_port = 22
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
    Name = "${var.project}-ssh"
    Owner = "${var.author}"
    Project = "${var.project}"
  }
}

resource "aws_security_group" "alb" {
  name = "${var.project}-alb"
  description = "Security group for the ALB"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = ["${aws_vpc.main.default_security_group_id}"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }

  tags {
    Name = "${var.project}-alb"
    Owner = "${var.author}"
    Project = "${var.project}"
  }
}
