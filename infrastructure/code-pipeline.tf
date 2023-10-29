resource "aws_codepipeline" "pipeline" {
  name     = format(module.naming.result, "backend-cpl")
  role_arn = aws_iam_role.codepipeline_iam_role.arn

  artifact_store {
    location = module.code_pipeline_s3_bucket.s3_bucket_id
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = 1
      run_order        = 1
      output_artifacts = ["source_output"]
      configuration = {
        Repo       = var.repository_name
        Branch     = var.target_branch_name
        OAuthToken = var.github_token
        Owner      = var.repository_owner
      }
    }
  }
  # BUILD
  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.backend_codebuild_project.id
      }
    }
  }
  # DEPLOY
  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["build_output"]

      configuration = {
        ClusterName = module.ecs_cluster.name
        ServiceName = module.ecs_backend_service.name
        FileName    = "imagedefinitions.json"
      }
    }
  }
}
