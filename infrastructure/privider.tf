terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.23.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  profile = "terraformprofile"
  region  = "ap-northeast-2"
}