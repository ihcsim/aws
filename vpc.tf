resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr}"
  assign_generated_ipv6_cidr_block = "${var.enabled_ipv6}"

  tags {
    Name = "${var.project}"
    Owner = "${var.author}"
    Project = "${var.project}"
  }
}

resource "aws_subnet" "public" {
  count = "${length(var.subnets_az)}"
  vpc_id = "${aws_vpc.main.id}"
  availability_zone = "${var.subnets_az[count.index]}"
  cidr_block= "${lookup(var.subnets_public_cidr, var.subnets_az[count.index])}"
  map_public_ip_on_launch = "true"

  tags {
    Name = "${var.subnets_az[count.index]}-public-${format("%02d", count.index)}"
    Owner = "${var.author}"
    Project = "${var.project}"
  }
}

resource "aws_subnet" "private" {
  count = "${length(var.subnets_az)}"
  vpc_id = "${aws_vpc.main.id}"
  availability_zone = "${var.subnets_az[count.index]}"
  cidr_block= "${lookup(var.subnets_private_cidr, var.subnets_az[count.index])}"

  tags {
    Name = "${var.subnets_az[count.index]}-private-${format("%02d", count.index)}"
    Owner = "${var.author}"
    Project = "${var.project}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.project}"
    Owner = "${var.author}"
    Project = "${var.project}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name = "${var.project}-public"
    Owner = "${var.author}"
    Project = "${var.project}"
  }
}

resource "aws_route_table_association" "public" {
  count = "${length(var.subnets_az)}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table" "private" {
  count = "${length(var.subnets_az)}"
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.nat.*.id, count.index)}"
  }

  tags {
    Name = "${var.project}-private-${format("%02d", count.index)}"
    Owner = "${var.author}"
    Project = "${var.project}"
  }
}

resource "aws_route_table_association" "private" {
  count = "${length(var.subnets_az)}"
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_nat_gateway" "nat" {
  depends_on = ["aws_internet_gateway.main", "aws_eip.nat"]

  count = "${length(var.subnets_az)}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"

  tags {
    Name = "${var.project}-${var.subnets_az[count.index]}"
    Owner = "${var.author}"
    Project = "${var.project}"
  }
}

resource "aws_eip" "nat" {
  count = "${length(var.subnets_az)}"
  vpc = "true"

  tags {
    Name = "${var.project}-${format("%02d", count.index)}"
    Owner = "${var.author}"
    Project = "${var.project}"  }
}
