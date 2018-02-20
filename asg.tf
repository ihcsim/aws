resource "aws_autoscaling_group" "web" {
  name = "${var.project}-web"
  min_size = "${var.web_asg_size["min"]}"
  max_size = "${var.web_asg_size["max"]}"
  availability_zones = "${var.subnets_az}"
  launch_configuration = "${aws_launch_configuration.web.name}"

  # needed for instance AssociatePublicIpAddress to work
  vpc_zone_identifier = ["${aws_subnet.public.*.id}"]

  tags = [
    {
      key = "Project"
      value = "${var.project}"
      propagate_at_launch = true
    },
    {
      key = "Owner"
      value = "${var.author}"
      propagate_at_launch = true
    }
  ]
}

resource "aws_launch_configuration" "web" {
  name_prefix = "${var.project}-web"
  instance_type = "${var.instance_type["web"]}"
  image_id = "${var.ubuntu_ami}"
  key_name = "${var.keypair_name}"
  associate_public_ip_address = "true"

  user_data = "${data.template_cloudinit_config.web.rendered}"
  security_groups = [
    "${aws_vpc.main.default_security_group_id}",
    "${aws_security_group.web.id}",
    "${aws_security_group.ssh.id}"
  ]

  root_block_device {
    volume_type = "gp2"
    volume_size = "8"
  }
}

data "template_cloudinit_config" "web" {
  part {
    content_type = "text/cloud-config"
    content = "${data.template_file.packages.rendered}"
  }

  part {
    content_type = "text/cloud-config"
    content = "${data.template_file.hosts.rendered}"
  }
}

data "template_file" "packages" {
  template = "${file("${path.module}/bootstrap/cloudinit/packages")}"
}

data "template_file" "hosts" {
  template = "${file("${path.module}/bootstrap/cloudinit/hosts")}"
}
