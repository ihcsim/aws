resource "aws_lb" "api_server" {
  name = "${var.project}-api-server-lb"
  internal = "false"
  security_groups = ["${aws_security_group.alb.id}", "${aws_vpc.main.default_security_group_id}"]
  subnets = ["${aws_subnet.public.*.id}"]

  access_logs = {
    bucket = "${var.elb_access_logs_bucket}"
    prefix = "api-servers/${var.elb_access_logs_bucket_prefix}"
    enabled = "true"
  }

  tags {
    Tier = "API Server"
    Owner = "${var.author}"
    Project = "${var.project}"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = "${aws_lb.api_server.arn}"
  port = "80"

  default_action {
    target_group_arn = "${aws_lb_target_group.http.arn}"
    type = "forward"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = "${aws_lb.api_server.arn}"
  port = "443"
  protocol = "HTTPS"

  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = "${var.ssl_cert_arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.http.arn}"
    type = "forward"
  }
}

resource "aws_lb_target_group" "http" {
  name_prefix = "apisvr"
  port = "8080"
  protocol = "HTTP"
  vpc_id = "${aws_vpc.main.id}"

  health_check {
    path = "/health"
  }

  tags {
    Tier = "API Server"
    Owner = "${var.author}"
    Project = "${var.project}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
