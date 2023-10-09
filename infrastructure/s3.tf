module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = format(module.naming.result, "log-s3-bucket")

  force_destroy = true

  # S3 bucket-level Public Access Block configuration (by default now AWS has made this default as true for S3 bucket-level block public access)
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = module.s3_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}
