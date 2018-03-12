provider "aws" {
  version = "~> 1.11"
  region = "${var.region}"
}

provider "template" {
  version = "~> 1.0"
}
