resource "aws_iam_instance_profile" "games" {
  name = "${var.author}-cloudwatch-agent"
  path = "/${var.project}/"
  role = "${aws_iam_role.games.name}"
}

resource "aws_iam_role" "games" {
  name = "${var.author}-games"
  path = "/${var.project}/"
  description = "IAM role for games nodes"
  assume_role_policy = "${data.aws_iam_policy_document.ec2_assume_role_policy.json}"
}

resource "aws_iam_role_policy" "games_cloudwatch_agent" {
  name = "games-cloudwatch-agent"
  role = "${aws_iam_role.games.id}"
  policy = "${data.aws_iam_policy_document.cloudwatch_agent.json}"
}

resource "aws_iam_role_policy" "games_sqs" {
  name = "games-sqs"
  role = "${aws_iam_role.games.id}"
  policy = "${data.aws_iam_policy_document.sqs.json}"
}
