variable "vpn_ip_address" {
  description = "vpn ip address for limited access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "db_name" {
  description = "database name"
  type        = string
  default     = "test"
}

variable "db_username" {
  description = "database admin username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "database password"
  type        = string
  default     = "admin123!"
}

variable "grafana_docker_image_url" {
  description = "grafana docker image url"
  type        = string
}

variable "loki_docker_image_url" {
  description = "loki docker image url"
  type        = string
}

variable "environment" {
  description = "environment"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "name of project"
  type        = string
  default     = "defaultproj"

  validation {
    condition     = length(var.project_name) < 11
    error_message = "length of project name should be less than 10 words."
  }
}

variable "repository_name" {
  description = "name of target repository name"
  type        = string
}

variable "repository_owner" {
  description = "name of repository owner"
  type        = string
}

variable "target_branch_name" {
  description = "name of target branch"
  type        = string
}

variable "github_token" {
  description = "github token for access repository"
  type        = string
}
