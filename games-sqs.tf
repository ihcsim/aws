resource "aws_sqs_queue" "games_payload" {
  name = "${var.project}-games-payload"
  visibility_timeout_seconds = "${var.sqs_visibility_timeout_seconds}"
  receive_wait_time_seconds = "20"

  tags = {
    Project = "${var.project}"
    Owner = "${var.author}"
  }
}
