terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.23.1"
    }
    grafana = {
      source = "grafana/grafana"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  profile = "terraformprofile"
  region  = "ap-northeast-2"
}

provider "grafana" {
  url  = "https://monit-${var.environment}.${var.domain_name}"
  auth = "${var.grafana_id}:${var.grafana_pw}"
}
