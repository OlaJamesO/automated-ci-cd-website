

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = var.bucket_name
  acl    = "private"

  # S3 bucket-level Public Access Block configuration
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  force_destroy           = true

  versioning = {
    enabled = true
  }

  attach_policy = true    
  policy    = data.aws_iam_policy_document.bucket_policy.json

  tags = {
    ManagedBy = "Terraform"
  }

}

data "aws_iam_policy_document" "bucket_policy" {

 statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${module.s3_bucket.s3_bucket_arn}/*"]

    principals {
      type        = "AWS"
      identifiers = module.cloudfront.cloudfront_origin_access_identity_iam_arns
    }
  }

 
}
