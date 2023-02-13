# Create a json file for CodeBuild's policy
data "aws_iam_policy_document" "CodeBuild_assume_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

# Create a role for CodeBuild
resource "aws_iam_role" "codebuild_assume_role" {
  name = "${var.bucket_name}-codebuild-role"

  assume_role_policy = data.aws_iam_policy_document.CodeBuild_assume_policy.json

}

# Create a json file for CodeBuild's policy
data "aws_iam_policy_document" "codebuild_policy" {

  statement {

    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:ListBucket",
      "s3:DeleteObject"
    ]

    resources = ["${module.s3_bucket.s3_bucket_arn}",
    "${module.s3_bucket.s3_bucket_arn}/*"]
  }

  statement {

    effect = "Allow"

    actions = [
      "codebuild:*"
    ]

    resources = ["${aws_codebuild_project.build_project.id}"]
  }

  statement {

    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]

  }

}


# Create CodeBuild policy
resource "aws_iam_role_policy" "attach_codebuild_policy" {
  name = "${var.bucket_name}-codebuild-policy"
  role = aws_iam_role.codebuild_assume_role.id

  policy = data.aws_iam_policy_document.codebuild_policy.json

}


# Create CodeBuild project
resource "aws_codebuild_project" "build_project" {
  name          = "${var.aws_codebuild_project_name}-website-build"
  description   = "CodeBuild project for ${var.bucket_name}"
  service_role  = aws_iam_role.codebuild_assume_role.arn
  build_timeout = "300"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  tags = {
    ManagedBy = "Terraform"
  }
}

resource "aws_codestarconnections_connection" "GitHub" {
  name          = "GitHub-connection"
  provider_type = "GitHub"
  tags = {
    ManagedBy = "Terraform"
  }
}

