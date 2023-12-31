module "ecs_task_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  role_name               = format(module.naming.result, "ecs-task-role")
  role_requires_mfa       = false
  create_role             = true
  create_instance_profile = true

  trusted_role_services = [
    "ecs-tasks.amazonaws.com"
  ]

  custom_role_policy_arns = [
    module.task_policy.arn
  ]
}

module "ecs_task_execution_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  role_name               = format(module.naming.result, "ecs-task-execution-role")
  role_requires_mfa       = false
  create_role             = true
  create_instance_profile = true

  trusted_role_services = [
    "ecs-tasks.amazonaws.com"
  ]

  custom_role_policy_arns = [
    module.task_execution_policy.arn,
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}

module "task_policy" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name        = format(module.naming.result, "task-policy")
  path        = "/"
  description = "task-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:*", "cloudwatch:*", "logs:*"],
      "Resource": "*"
    }
  ]
}
EOF
}

module "task_execution_policy" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name        = format(module.naming.result, "task-execution-policy")
  path        = "/"
  description = "task-execution-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:*", "cloudwatch:*", "logs:*"],
      "Resource": "*"
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  policy_id = format(module.naming.result, "s3-access-policy-document")

  statement {
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    effect = "Allow"
    resources = [
      "${module.s3_bucket.s3_bucket_arn}/*",
      "${module.s3_bucket.s3_bucket_arn}"
    ]
    principals {
      identifiers = ["600734575887"] #ap-northeast-2 ALB service account
      type        = "AWS"
    }
  }
}

resource "aws_iam_user" "iam_user" {
  name          = format(module.naming.result, "s3-loki-access-iam-user")
  force_destroy = true
}

resource "aws_iam_access_key" "iam_user_access_key" {
  user = aws_iam_user.iam_user.name
}

resource "aws_iam_user_policy" "iam_user_policy" {
  name   = format(module.naming.result, "s3-loki-access-iam-user-policy")
  user   = aws_iam_user.iam_user.name
  policy = file("./files/s3-policy.json")
}

resource "aws_iam_role" "codebuild_iam_role" {
  name = format(module.naming.result, "cd-iam-role")
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_iam_policy" {
  role = aws_iam_role.codebuild_iam_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
        "ecr:UploadLayerPart", "ssm:*"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
        "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
        "s3:GetBucketLocation"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "codepipeline_iam_role" {
  name = format(module.naming.result, "cpl-iam-role")

  assume_role_policy = file("./files/codepipeline-assume-role.json")

  # code pipeline 생성 시 생성되는 default iam role policy
  inline_policy {
    name   = format(module.naming.result, "cpl-iam-policy")
    policy = file("./files/codepipeline-default-policy.json")
  }
}
