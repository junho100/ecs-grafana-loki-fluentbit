variable "environment" {
  description = "environment (prod, stage, dev, ...)"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "name of project"
  type        = string
  default     = "default-project"
}
