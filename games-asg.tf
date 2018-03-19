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
  iam_instance_profile = "${aws_iam_instance_profile.games.id}"

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

resource "aws_autoscaling_policy" "games_cpu" {
  name = "games-cpu"
  autoscaling_group_name = "${aws_autoscaling_group.games.name}"
  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = "${var.metrics_alarm_games_cpu_target}"
  }
}

resource "aws_cloudwatch_metric_alarm" "games_cpu" {
  alarm_name = "games-cpu-alarm"
  alarm_description = "Games EC2 instances metric alarm to maintain CPU capacity"

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "60"
  statistic = "Average"
  threshold = "${var.metrics_alarm_games_cpu_target}"

  alarm_actions = ["${aws_autoscaling_policy.games_cpu.arn}"]

  dimensions {
    AUtoScalingGroupName = "${aws_autoscaling_group.games.name}"
  }
}

resource "aws_autoscaling_policy" "games_network_in" {
  name = "games-network-in"
  autoscaling_group_name = "${aws_autoscaling_group.games.name}"
  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageNetworkIn"
    }

    target_value = "${var.metrics_alarm_games_network_in_target}"
  }
}

resource "aws_cloudwatch_metric_alarm" "games_network_in" {
  alarm_name = "games-network-in-alarm"
  alarm_description = "Games EC2 instances metric alarm to maintain network-in capacity"

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "NetworkIn"
  namespace = "AWS/EC2"
  period = "60"
  statistic = "Average"
  threshold = "${var.metrics_alarm_games_network_in_target}"

  alarm_actions = ["${aws_autoscaling_policy.games_network_in.arn}"]

  dimensions {
    AUtoScalingGroupName = "${aws_autoscaling_group.games.name}"
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
    merge_type = "list(append)+dict(recurse_array)+str()"
  }

  part {
    content_type = "text/cloud-config"
    content = "${data.template_file.cloudwatch_agent.rendered}"
    merge_type = "list(append)+dict(recurse_array)+str()"
  }

  part {
    content_type = "text/cloud-config"
    content = "${data.template_file.docker_ce.rendered}"
    merge_type = "list(append)+dict(recurse_array)+str()"
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
    device_name = "${var.data_block_volume_devices["games"]}"
  }
}

data "template_file" "cloudwatch_agent" {
  template = "${file("${path.module}/bootstrap/cloudinit/games/cloudwatch_agent")}"

  vars {
    download_url = "${var.cloudwatch_agent_download_url["linux_amd64"]}"
    config_file_path = "${var.cloudwatch_agent_config_remote_path}"
    config_file_content = "${jsonencode(data.template_file.cloudwatch_agent_config.rendered)}"
  }
}

data "template_file" "cloudwatch_agent_config" {
  template = "${file("${path.module}/bootstrap/config/games/cloudwatch_agent.json")}"

  vars {
    namespace_suffix = "${var.author}"
    region = "${var.region}"
    logfile = "${var.games_data_folder}/cloudwatch_agent.log"
  }
}
