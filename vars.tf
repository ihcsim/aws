variable "region" {}
variable "keypair_name" {}

variable "project" {
  default = "isim-ao-training"
}

variable "author" {
  default = "isim"
}

variable "vpc_cidr" {
  default = "10.50.0.0/16"
}

variable "enabled_ipv6" {
  default = "true"
}

variable "subnets_az" {
  default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "subnets_public_cidr" {
  default = {
    "us-west-2a" = "10.50.10.0/24"
    "us-west-2b" = "10.50.20.0/24"
    "us-west-2c" = "10.50.30.0/24"
  }
}

variable "subnets_private_cidr" {
  default = {
    "us-west-2a" = "10.50.90.0/24"
    "us-west-2b" = "10.50.100.0/24"
    "us-west-2c" = "10.50.200.0/24"
  }
}

variable "api_server_asg_size" {
  default = {
    "min" = 1
    "max" = 5
  }
}

variable "games_asg_size" {
  default = {
    "min" = 1
    "max" = 5
  }
}

variable "instance_type" {
  default = {
    "api_server" = "t2.micro"
    "games" = "t2.micro"
    "analytics" = "t2.micro"
  }
}

variable "root_block_volume_types" {
  default = {
    "api_server" = "gp2"
    "games" = "gp2"
    "analytics" = "gp2"
  }
}

variable "root_block_volume_sizes" {
  default = {
    "api_server" = "8"
    "games" = "8"
    "analytics" = "8"
  }
}

variable "data_block_volume_devices" {
  default = {
    "games" = "/dev/xvdf"
    "analytics" = "/dev/xvdf"
  }
}

variable "data_block_volume_types" {
  default = {
    "games" = "gp2"
    "analytics" = "gp2"
  }
}

variable "data_block_volume_sizes" {
  default = {
    "games" = "4"
    "analytics" = "4"
  }
}

variable "ubuntu_ami" {
  default = "ami-79873901"
}

variable "metrics_alarm_api_server_cpu_thresholds" {
  default = {
    "upper" = "70"
    "lower" = "50"
  }
}

variable "metrics_alarm_api_server_network_thresholds" {
  default = {
    "upper" = "1000000"
    "lower" = "500000"
  }
}

variable "metrics_alarm_games_cpu_target" {
  default = "70"
}

variable "metrics_alarm_games_network_in_target" {
  default = "1000000"
}


variable "ssl_cert_arn" {}

variable "elb_access_logs_bucket" {}
variable "elb_access_logs_bucket_prefix" {}

variable "games_user" {
  default = "gamer"
}

variable "games_data_folder" {
  default = "/opt/games/data"
}

variable "cloudwatch_agent_download_url" {
  default = {
    "linux_amd64" = "https://s3.amazonaws.com/amazoncloudwatch-agent/linux/amd64/latest/AmazonCloudWatchAgent.zip"
  }
}

variable "cloudwatch_agent_config_remote_path" {
  default = "/opt/aws/cloudwatch_agent.config"
}
