resource "aws_iam_instance_profile" "nodes" {
  name_prefix = "${var.author}-cloudwatch-agent"
  path = "/${var.project}/"
  role = "${aws_iam_role.nodes.name}"
}

resource "aws_iam_role" "nodes" {
  name = "${var.author}-nodes"
  path = "/${var.project}/"
  description = "IAM role for nodes"
  assume_role_policy = "${data.aws_iam_policy_document.ec2_assume_role_policy.json}"
}

resource "aws_iam_role_policy" "nodes_cloudwatch_agent" {
  name = "nodes-cloudwatch-agent"
  role = "${aws_iam_role.nodes.id}"
  policy = "${data.aws_iam_policy_document.cloudwatch_agent.json}"
}

resource "aws_iam_role_policy" "nodes_sqs" {
  name = "nodes-sqs"
  role = "${aws_iam_role.nodes.id}"
  policy = "${data.aws_iam_policy_document.sqs.json}"
}
