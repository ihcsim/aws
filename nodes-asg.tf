resource "aws_autoscaling_group" "nodes" {
  name = "${var.project}-nodes"
  min_size = "${var.nodes_asg_size["min"]}"
  max_size = "${var.nodes_asg_size["max"]}"
  desired_capacity = "${var.nodes_asg_size["min"]}"
  availability_zones = "${var.subnets_az}"
  launch_configuration = "${aws_launch_configuration.nodes.name}"

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
      value = "Nodes"
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

resource "aws_launch_configuration" "nodes" {
  name_prefix = "${var.project}-nodes"
  instance_type = "${var.instance_type["nodes"]}"
  image_id = "${var.ubuntu_ami}"
  key_name = "${var.keypair_name}"
  iam_instance_profile = "${aws_iam_instance_profile.nodes.id}"

  user_data = "${data.template_cloudinit_config.nodes.rendered}"
  security_groups = [
    "${aws_vpc.main.default_security_group_id}",
    "${aws_security_group.nodes.id}"
  ]

  root_block_device {
    volume_type = "${var.root_block_volume_types["nodes"]}"
    volume_size = "${var.root_block_volume_sizes["nodes"]}"
  }

  ebs_block_device {
    device_name = "${var.data_block_volume_devices["nodes"]}"
    volume_type = "${var.data_block_volume_types["nodes"]}"
    volume_size = "${var.data_block_volume_sizes["nodes"]}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "nodes_cpu" {
  name = "nodes-cpu"
  autoscaling_group_name = "${aws_autoscaling_group.nodes.name}"
  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = "${var.metrics_alarm_nodes_cpu_target}"
  }
}

resource "aws_cloudwatch_metric_alarm" "nodes_cpu" {
  alarm_name = "nodes-cpu-alarm"
  alarm_description = "EC2 instances metric alarm to maintain CPU capacity"

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "60"
  statistic = "Average"
  threshold = "${var.metrics_alarm_nodes_cpu_target}"

  alarm_actions = ["${aws_autoscaling_policy.nodes_cpu.arn}"]

  dimensions {
    AUtoScalingGroupName = "${aws_autoscaling_group.nodes.name}"
  }
}

resource "aws_autoscaling_policy" "nodes_network_in" {
  name = "nodes-network-in"
  autoscaling_group_name = "${aws_autoscaling_group.nodes.name}"
  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageNetworkIn"
    }

    target_value = "${var.metrics_alarm_nodes_network_in_target}"
  }
}

resource "aws_cloudwatch_metric_alarm" "nodes_network_in" {
  alarm_name = "nodes-network-in-alarm"
  alarm_description = "EC2 instances metric alarm to maintain network-in capacity"

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "NetworkIn"
  namespace = "AWS/EC2"
  period = "60"
  statistic = "Average"
  threshold = "${var.metrics_alarm_nodes_network_in_target}"

  alarm_actions = ["${aws_autoscaling_policy.nodes_network_in.arn}"]

  dimensions {
    AUtoScalingGroupName = "${aws_autoscaling_group.nodes.name}"
  }
}

data "template_cloudinit_config" "nodes" {
  part {
    content_type = "text/cloud-config"
    content = "${data.template_file.nodes_packages.rendered}"
    merge_type = "list(append)+dict(recurse_array)+str()"
  }

  part {
    content_type = "text/cloud-config"
    content = "${data.template_file.nodes_mounts.rendered}"
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

  part {
    content_type = "text/cloud-config"
    content = "${data.template_file.games_agent.rendered}"
    merge_type = "list(append)+dict(recurse_array)+str()"
  }
}

data "template_file" "nodes_packages" {
  template = "${file("${path.module}/bootstrap/cloudinit/nodes/packages")}"
}

data "template_file" "nodes_mounts" {
  template = "${file("${path.module}/bootstrap/cloudinit/nodes/mounts")}"

  vars {
    user = "${var.nodes_user}"
    data_folder = "${var.nodes_data_folder}"
    device_name = "${var.data_block_volume_devices["nodes"]}"
  }
}

data "template_file" "cloudwatch_agent" {
  template = "${file("${path.module}/bootstrap/cloudinit/nodes/cloudwatch_agent")}"

  vars {
    download_url = "${var.cloudwatch_agent_download_url["linux_amd64"]}"
    config_file_path = "${var.cloudwatch_agent_config_remote_path}"
    config_file_content = "${jsonencode(data.template_file.cloudwatch_agent_config.rendered)}"
  }
}

data "template_file" "cloudwatch_agent_config" {
  template = "${file("${path.module}/bootstrap/config/nodes/cloudwatch_agent.json")}"

  vars {
    namespace_suffix = "${var.author}"
    region = "${var.region}"
    logfile = "${var.nodes_data_folder}/cloudwatch_agent.log"
  }
}

data "template_file" "games_agent" {
  template = "${file("${path.module}/bootstrap/cloudinit/nodes/application")}"

  vars {
    region = "${var.region}"
    image = "${aws_ecr_repository.games_agent.repository_url}"
    version = "${var.apps_version["games_agent"]}"
  }
}
