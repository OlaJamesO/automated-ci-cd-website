#  Create a json file for CodePipeline's policy

data "aws_iam_policy_document" "codepipeline_assume_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

# Create a role for CodePipeline
resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.bucket_name}-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_policy.json
}

# Create a json file for CodePipeline's policy needed to use GitHub and CodeBuild
data "aws_iam_policy_document" "codepipeline_policy" {

  statement {

    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject"
    ]

    resources = ["${module.s3_bucket.s3_bucket_arn}",
    "${module.s3_bucket.s3_bucket_arn}/*"]
  }

  statement {

    effect = "Allow"

    actions = [
      "codestar-connections:UseConnection"
    ]

    resources = ["${aws_codestarconnections_connection.GitHub.arn}"]
  }

  statement {

    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]

    resources = ["*"]

  }

}

# CodePipeline policy needed to use GitHub and CodeBuild
resource "aws_iam_role_policy" "attach_codepipeline_policy" {

  name = "${var.bucket_name}-codepipeline-policy"
  role = aws_iam_role.codepipeline_role.id

  policy = data.aws_iam_policy_document.codepipeline_policy.json

}

# Create CodePipeline
resource "aws_codepipeline" "codepipeline" {

  name     = "${var.bucket_name}-codepipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {

    location = module.s3_bucket.s3_bucket_id
    type     = "S3"
  }

  stage {

    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.GitHub.arn
        FullRepositoryId = "OlaJamesO/game-static-website"
        BranchName       = "main"
      }
    }
  }
  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["OutputArtifact"]
      version          = "1"


      configuration = {
        ProjectName = aws_codebuild_project.build_project.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["OutputArtifact"]
      version         = "1"

      configuration = {
        BucketName = var.bucket_name
        Extract    = "true"
      }
    }
  }

  tags = {
    ManagedBy = "Terraform"
  }

}
