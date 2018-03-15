resource "aws_sqs_queue" "games_payload" {
  name = "${var.project}-games-payload"
  visibility_timeout_seconds = "${var.sqs_visibility_timeout_seconds}"

  tags = {
    Project = "${var.project}"
    Owner = "${var.author}"
  }
}
