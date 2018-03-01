resource "aws_autoscaling_group" "web" {
  name = "${var.project}-web"
  min_size = "${var.web_asg_size["min"]}"
  max_size = "${var.web_asg_size["max"]}"
  desired_capacity = "${var.web_asg_size["min"]}"
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

resource "aws_autoscaling_policy" "web-cpu-grow" {
  name = "web-cpu-grow"
  autoscaling_group_name = "${aws_autoscaling_group.web.name}"
  adjustment_type = "PercentChangeInCapacity"
  policy_type = "StepScaling"
  min_adjustment_magnitude = 1

  # if 80 <= cpu_util < 90, increase desired capacity by 10%
  # 10% of 1 is rounded to 1
  step_adjustment {
    scaling_adjustment = 10
    metric_interval_lower_bound = 10
    metric_interval_upper_bound = 20
  }

  # if cpu_util >= 90, increase desired capacity by 20%
  # 20% of 2 is rounded to 1.
  step_adjustment {
    scaling_adjustment = 20
    metric_interval_lower_bound = 20
  }
}

resource "aws_cloudwatch_metric_alarm" "web-cpu-grow" {
  alarm_name = "web-cpu-alarm-grow"
  alarm_description = "Web tier EC2 instances metrics alarm to increase capacity"

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "${var.metrics_alarm_web_cpu_upper_threshold}"

  alarm_actions = ["${aws_autoscaling_policy.web-cpu-grow.arn}"]

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.web.name}"
  }
}

resource "aws_autoscaling_policy" "web-cpu-shrink" {
  name = "web-cpu-shrink"
  autoscaling_group_name = "${aws_autoscaling_group.web.name}"
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

resource "aws_cloudwatch_metric_alarm" "web-cpu-shrink" {
  alarm_name = "web-cpu-alarm-shrink"
  alarm_description = "Web tier EC2 instances metrics alarm to decrease capacity"

  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "${var.metrics_alarm_web_cpu_lower_threshold}"

  alarm_actions = ["${aws_autoscaling_policy.web-cpu-shrink.arn}"]

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.web.name}"
  }
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

  lifecycle {
    create_before_destroy = true
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
