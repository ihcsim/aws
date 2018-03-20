resource "aws_iam_instance_profile" "api_server" {
  name_prefix = "${var.author}-api-server"
  path = "/${var.project}/"
  role = "${aws_iam_role.api_server.name}"
}

resource "aws_iam_role" "api_server" {
  name = "${var.author}-api-server"
  path = "/${var.project}/"
  description = "IAM role for API Server"
  assume_role_policy = "${data.aws_iam_policy_document.ec2_assume_role_policy.json}"
}

resource "aws_iam_role_policy" "api_server_sqs" {
  name = "api-server-sqs"
  role = "${aws_iam_role.api_server.id}"
  policy = "${data.aws_iam_policy_document.sqs.json}"
}

resource "aws_iam_role_policy" "api_server_ecr" {
  name = "api-server-ecr"
  role = "${aws_iam_role.api_server.id}"
  policy = "${data.aws_iam_policy.ecr_read_only.policy}"
}
