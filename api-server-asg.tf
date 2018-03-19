resource "aws_autoscaling_group" "api_server" {
  name = "${var.project}-api-server"
  min_size = "${var.api_server_asg_size["min"]}"
  max_size = "${var.api_server_asg_size["max"]}"
  desired_capacity = "${var.api_server_asg_size["min"]}"
  availability_zones = "${var.subnets_az}"
  launch_configuration = "${aws_launch_configuration.api_server.name}"

  health_check_type = "ELB"
  target_group_arns = ["${aws_lb_target_group.http.arn}"]

  # needed for instance AssociatePublicIpAddress to work
  vpc_zone_identifier = ["${aws_subnet.public.*.id}"]

  tags = [
    {
      key = "Tier"
      value = "API Server"
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

resource "aws_launch_configuration" "api_server" {
  name_prefix = "${var.project}-api-server"
  instance_type = "${var.instance_type["api_server"]}"
  image_id = "${var.ubuntu_ami}"
  key_name = "${var.keypair_name}"
  associate_public_ip_address = "true"
  iam_instance_profile = "${aws_iam_instance_profile.api_server.id}"

  user_data = "${data.template_cloudinit_config.api_server.rendered}"
  security_groups = [
    "${aws_vpc.main.default_security_group_id}",
    "${aws_security_group.api_server.id}",
    "${aws_security_group.ssh.id}"
  ]

  root_block_device {
    volume_type = "${var.root_block_volume_types["api_server"]}"
    volume_size = "${var.root_block_volume_sizes["api_server"]}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "api_server_cpu_grow" {
  name = "api-server-cpu-grow"
  autoscaling_group_name = "${aws_autoscaling_group.api_server.name}"
  adjustment_type = "PercentChangeInCapacity"
  policy_type = "StepScaling"
  min_adjustment_magnitude = 1

  # if 80 <= cpu_util_percent < 90, increase desired capacity by 10%
  # 10% of 1 is rounded to 1
  step_adjustment {
    scaling_adjustment = 10
    metric_interval_lower_bound = 10
    metric_interval_upper_bound = 20
  }

  # if cpu_util_percent >= 90, increase desired capacity by 20%
  # 20% of 2 is rounded to 1.
  step_adjustment {
    scaling_adjustment = 20
    metric_interval_lower_bound = 20
  }
}

resource "aws_cloudwatch_metric_alarm" "api_server_cpu_grow" {
  alarm_name = "api-server-cpu-alarm-grow"
  alarm_description = "API Servers EC2 instances CPU metric alarm to increase capacity"

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "${var.metrics_alarm_api_server_cpu_thresholds["upper"]}"

  alarm_actions = ["${aws_autoscaling_policy.api_server_cpu_grow.arn}"]

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.api_server.name}"
  }
}

resource "aws_autoscaling_policy" "api_server_cpu_shrink" {
  name = "api_server-cpu-shrink"
  autoscaling_group_name = "${aws_autoscaling_group.api_server.name}"
  adjustment_type = "PercentChangeInCapacity"
  policy_type = "StepScaling"
  min_adjustment_magnitude = 1

  # if 50 <= cpu_util < 60, decrease desired capacity by 10%
  step_adjustment {
    scaling_adjustment = -10
    metric_interval_lower_bound = -20
    metric_interval_upper_bound = -10
  }

  # if cpu_util < 50, decrease desired capacity by 20%
  step_adjustment {
    scaling_adjustment = -20
    metric_interval_upper_bound = -20
  }
}

resource "aws_cloudwatch_metric_alarm" "api_server_cpu_shrink" {
  alarm_name = "api-server-cpu-alarm-shrink"
  alarm_description = "API Server EC2 instances CPU metric alarm to decrease capacity"

  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "${var.metrics_alarm_api_server_cpu_thresholds["lower"]}"

  alarm_actions = ["${aws_autoscaling_policy.api_server_cpu_shrink.arn}"]

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.api_server.name}"
  }
}

resource "aws_autoscaling_policy" "api_server_network_grow" {
  name = "api-server-network-grow"
  autoscaling_group_name = "${aws_autoscaling_group.api_server.name}"
  adjustment_type = "PercentChangeInCapacity"
  policy_type = "StepScaling"
  min_adjustment_magnitude = 1

  # if 1000000 <= network_in_bytes < 2000000, increase desired capacity by 10%
  # 10% of 1 is rounded to 1
  step_adjustment {
    scaling_adjustment = 10
    metric_interval_lower_bound = 0
    metric_interval_upper_bound = 1000000
  }

  # if network_in >= 2000000, increase desired capacity by 20%
  # 20% of 2 is rounded to 1.
  step_adjustment {
    scaling_adjustment = 20
    metric_interval_lower_bound = 1000000
  }
}

resource "aws_cloudwatch_metric_alarm" "api_server_network_grow" {
  alarm_name = "api-server-network-alarm-grow"
  alarm_description = "API Server EC2 instances network metric alarm to increase capacity"

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "NetworkIn"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "${var.metrics_alarm_api_server_network_thresholds["upper"]}"

  alarm_actions = ["${aws_autoscaling_policy.api_server_network_grow.arn}"]

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.api_server.name}"
  }
}

resource "aws_autoscaling_policy" "api_server_network_shrink" {
  name = "api-server-network-shrink"
  autoscaling_group_name = "${aws_autoscaling_group.api_server.name}"
  adjustment_type = "PercentChangeInCapacity"
  policy_type = "StepScaling"
  min_adjustment_magnitude = 1

  # if 250000 <= network_in_bytes < 500000, increase desired capacity by 10%
  # 10% of 1 is rounded to 1
  step_adjustment {
    scaling_adjustment = -10
    metric_interval_upper_bound = 0
    metric_interval_lower_bound = -250000
  }

  # if network_in < 250000, increase desired capacity by 20%
  # 20% of 2 is rounded to 1.
  step_adjustment {
    scaling_adjustment = -20
    metric_interval_upper_bound = -250000
  }
}

resource "aws_cloudwatch_metric_alarm" "api-server-network-shrink" {
  alarm_name = "api-server-network-alarm-shrink"
  alarm_description = "api_server tier EC2 instances network metric alarm to decrease capacity"

  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "NetworkIn"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "${var.metrics_alarm_api_server_network_thresholds["lower"]}"

  alarm_actions = ["${aws_autoscaling_policy.api_server_network_shrink.arn}"]

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.api_server.name}"
  }
}

data "template_cloudinit_config" "api_server" {
  part {
    content_type = "text/cloud-config"
    content = "${data.template_file.api_server_packages.rendered}"
  }

  part {
    content_type = "text/cloud-config"
    content = "${data.template_file.hosts.rendered}"
    merge_type = "list(append)+dict(recurse_array)+str()"
  }

  part {
    content_type = "text/cloud-config"
    content = "${data.template_file.docker_ce.rendered}"
    merge_type = "list(append)+dict(recurse_array)+str()"
  }
}

data "template_file" "api_server_packages" {
  template = "${file("${path.module}/bootstrap/cloudinit/api-server/packages")}"
}

data "template_file" "hosts" {
  template = "${file("${path.module}/bootstrap/cloudinit/hosts")}"
}

data "template_file" "docker_ce" {
  template = "${file("${path.module}/bootstrap/cloudinit/docker-ce/packages")}"

  vars {
    download_url = "${var.docker_download_url}"
    docker_version = "${var.docker_version}"
    gpg_fingerprint = "${var.docker_gpg_fingerprint}"
    gpg_url = "${var.docker_gpg_url}"
    os_user = "${var.os_user}"
  }
}
