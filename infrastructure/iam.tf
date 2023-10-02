module "ecs_task_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  role_name               = "ecs-task-role"
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

  role_name               = "ecs-task-execution-role"
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

  name        = "task-policy"
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

  name        = "task-execution-policy"
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
  policy_id = "s3_bucket_lb_logs"

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
  name          = "test-log-iam"
  force_destroy = true
}

resource "aws_iam_access_key" "iam_user_access_key" {
  user = aws_iam_user.iam_user.name
}

resource "aws_iam_user_policy" "iam_user_policy" {
  name   = "test-iam-user-policy"
  user   = aws_iam_user.iam_user.name
  policy = file("s3-policy.json")
}

