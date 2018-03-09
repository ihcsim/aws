# To test:
# ELB and target group
# Metrics

resource "aws_autoscaling_group" "games" {
  name = "${var.project}-games-nodes"
  min_size = "${var.games_asg_size["min"]}"
  max_size = "${var.games_asg_size["max"]}"
  desired_capacity = "${var.games_asg_size["min"]}"
  availability_zones = "${var.subnets_az}"
  launch_configuration = "${aws_launch_configuration.games.name}"

  vpc_zone_identifier = ["${aws_subnet.private.*.id}"]

  enabled_metrics = [
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  #health_check_type = "ELB"
  #target_group_arns = ["${aws_lb_target_group.games.arn}"]

  tags = [
    {
      key = "Tier"
      value = "Games Nodes"
      propagate_at_launch = true
    },
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

resource "aws_launch_configuration" "games" {
  name_prefix = "${var.project}-games-nodes"
  instance_type = "${var.instance_type["games"]}"
  image_id = "${var.ubuntu_ami}"
  key_name = "${var.keypair_name}"

  user_data = "${data.template_cloudinit_config.games.rendered}"
  security_groups = [
    "${aws_vpc.main.default_security_group_id}",
    "${aws_security_group.games.id}"
  ]

  root_block_device {
    volume_type = "${var.root_block_volume_types["games"]}"
    volume_size = "${var.root_block_volume_sizes["games"]}"
  }

  ebs_block_device {
    device_name = "${var.data_block_volume_devices["games"]}"
    volume_type = "${var.data_block_volume_types["games"]}"
    volume_size = "${var.data_block_volume_sizes["games"]}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "template_cloudinit_config" "games" {
  part {
    content_type = "text/cloud-config"
    content = "${data.template_file.games_packages.rendered}"
  }

  part {
    content_type = "text/cloud-config"
    content = "${data.template_file.games_mounts.rendered}"
  }

  part {
    content_type = "text/cloud-config"
    content = "${data.template_file.hosts.rendered}"
  }
}

data "template_file" "games_packages" {
  template = "${file("${path.module}/bootstrap/cloudinit/games/packages")}"
}

data "template_file" "games_mounts" {
  template = "${file("${path.module}/bootstrap/cloudinit/games/mounts")}"

  vars {
    user = "${var.games_user}"
    data_folder = "${var.games_data_folder}"
    device_name = "${var.games_volume_device_name}"
  }
}
