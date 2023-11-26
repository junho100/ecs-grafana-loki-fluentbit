variable "environment" {
  description = "environment"
  type        = string
  default     = "prod"
}

variable "domain_name" {
  description = "domain name for connecting service"
  type        = string
}

variable "grafana_id" {
  description = "grafana admin id"
  type        = string
}

variable "grafana_pw" {
  description = "grafana admin pw"
  type        = string
}
