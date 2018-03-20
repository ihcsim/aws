resource "aws_ecr_repository" "api_server" {
  name = "${var.project}/api-server"
}

resource "aws_ecr_repository" "games_agent" {
  name = "${var.project}/games-agent"
}

data "aws_iam_policy" "ecr_read_only" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

output "ecr_registry_id" {
  value = "${aws_ecr_repository.api_server.registry_id}"
}

output "repositories_url" {
  value = "${map("API Server", "${aws_ecr_repository.api_server.repository_url}", "Games Agent", "${aws_ecr_repository.games_agent.repository_url}")}"
}
