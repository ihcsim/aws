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

variable "nodes_asg_size" {
  default = {
    "min" = 1
    "max" = 5
  }
}

variable "instance_type" {
  default = {
    "api_server" = "t2.small"
    "nodes" = "t2.small"
    "analytics" = "t2.small"
  }
}

variable "root_block_volume_types" {
  default = {
    "api_server" = "gp2"
    "nodes" = "gp2"
    "analytics" = "gp2"
  }
}

variable "root_block_volume_sizes" {
  default = {
    "api_server" = "8"
    "nodes" = "8"
    "analytics" = "8"
  }
}

variable "data_block_volume_devices" {
  default = {
    "nodes" = "/dev/xvdf"
    "analytics" = "/dev/xvdf"
  }
}

variable "data_block_volume_types" {
  default = {
    "nodes" = "gp2"
    "analytics" = "gp2"
  }
}

variable "data_block_volume_sizes" {
  default = {
    "nodes" = "4"
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

variable "metrics_alarm_nodes_cpu_target" {
  default = "70"
}

variable "metrics_alarm_nodes_network_in_target" {
  default = "1000000"
}


variable "ssl_cert_arn" {}

variable "elb_access_logs_bucket" {}
variable "elb_access_logs_bucket_prefix" {}

variable "nodes_user" {
  default = "gamer"
}

variable "nodes_data_folder" {
  default = "/opt/nodes/data"
}

variable "cloudwatch_agent_download_url" {
  default = {
    "linux_amd64" = "https://s3.amazonaws.com/amazoncloudwatch-agent/linux/amd64/latest/AmazonCloudWatchAgent.zip"
  }
}

variable "cloudwatch_agent_config_remote_path" {
  default = "/opt/aws/cloudwatch_agent.config"
}

variable "sqs_visibility_timeout_seconds" {
  default = 120
}

variable "docker_version" {
  default = "17.12.1~ce-0~ubuntu"
}

variable "docker_download_url" {
  default = "https://download.docker.com/linux/ubuntu"
  description = "Refer https://docs.docker.com/install/linux/docker-ce/ubuntu/"
}

variable "docker_gpg_url" {
  default = "https://download.docker.com/linux/ubuntu/gpg"
  description = "Refer https://docs.docker.com/install/linux/docker-ce/ubuntu/"
}

variable "docker_gpg_fingerprint" {
  default = "9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88"
  description = "Refer https://docs.docker.com/install/linux/docker-ce/ubuntu/"
}

variable "os_user" {
  default = "ubuntu"
}

variable "apps_version" {
  default = {
    "api_server" = "0.0.1"
    "games_agent" = "0.0.1"
  }
}
