resource "aws_codebuild_project" "backend_codebuild_project" {
  name         = format(module.naming.result, "backend-cd-project")
  service_role = aws_iam_role.codebuild_iam_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec/buildspec-${var.environment}.yml"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:6.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }
}
