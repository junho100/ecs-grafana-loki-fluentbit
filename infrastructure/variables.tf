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

variable "backend_docker_image_url" {
  description = "backend docker image url"
  type        = string
  default     = ""
}
