resource "aws_iam_instance_profile" "cloudwatch_agent" {
  name = "${var.author}-cloudwatch-agent"
  path = "/${var.project}/"
  role = "${aws_iam_role.cloudwatch_agent.name}"
}

resource "aws_iam_role" "cloudwatch_agent" {
  name = "${var.author}-cloudwatch-agent"
  path = "/${var.project}/"
  description = "IAM role for games nodes to run CloudWatch agent"
  assume_role_policy = "${data.aws_iam_policy_document.ec2_assume_role_policy.json}"
}

resource "aws_iam_role_policy" "cloudwatch_agent" {
  name = "${var.project}-cloudwatch-agent"
  role = "${aws_iam_role.cloudwatch_agent.id}"
  policy = "${data.aws_iam_policy_document.cloudwatch_agent.json}"
}

resource "aws_iam_role_policy" "games" {
  name = "${var.project}-ec2-ssm"
  role = "${aws_iam_role.cloudwatch_agent.id}"
  policy = "${data.aws_iam_policy.ec2_role_for_ssm.policy}"
}

data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cloudwatch_agent" {
  statement {
    sid =  "CloudWatchAgentServerPolicy"
    effect =  "Allow"
    actions = [
      "logs:CreateLogStream",
      "cloudwatch:PutMetricData",
      "ec2:DescribeTags",
      "logs:DescribeLogStreams",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "ssm:GetParameter"
    ],
    resources =  ["*"]
  }
}

data "aws_iam_policy" "ec2_role_for_ssm" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}
