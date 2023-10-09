variable "environment" {
  description = "environment (prod, stage, dev, ...)"
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
