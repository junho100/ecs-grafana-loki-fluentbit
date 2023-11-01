terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.23.1"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  profile = "terraformprofile"
  region  = "ap-northeast-2"
}
