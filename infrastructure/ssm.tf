resource "aws_ssm_parameter" "backend_ecr_url_ssm_parameter" {
  name  = "/${var.project_name}/backend/${var.environment}/ecr-url"
  type  = "String"
  value = aws_ecr_repository.backend_ecr_repository.repository_url
}
