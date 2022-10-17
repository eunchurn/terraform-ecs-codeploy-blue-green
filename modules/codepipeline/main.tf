locals {
  github_owner = "mystack-platform"
  github_repo  = var.api_repository_name
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket        = "${var.random_id_prefix}-codepipeline-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "codepipeline_acl" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "codepipeline_bucket_access_block" {
  bucket = aws_s3_bucket.codepipeline_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# Role for AWS CodePipeline
resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.random_id_prefix}-codepipeline-role"
  assume_role_policy = file("${path.module}/policies/code-pipeline-role.json")
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "${var.random_id_prefix}-codepipeline-policy"
  policy = file("${path.module}/policies/codepipeline-service-role-policy.json")
  role   = aws_iam_role.codepipeline_role.id
}

# Console Action 필요: CodePipeline > Settings
resource "aws_codestarconnections_connection" "github" {
  name          = "github-connection"
  provider_type = "GitHub"
}

resource "aws_codepipeline" "codepipeline_blue-green_api" {
  name     = "${var.random_id_prefix}-${var.api_pipeline_name}-${terraform.workspace}-blue-green"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    # https://github.com/hashicorp/terraform-provider-aws/issues/2796#issuecomment-399229140
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = "${aws_codestarconnections_connection.github.arn}"
        FullRepositoryId = "mystack-platform/mystack-api"
        BranchName       = "deploy/${terraform.workspace}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = var.buildproject_name
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["buildout"]
      version          = "1"

      configuration = {
        ProjectName = "${var.buildproject_name}"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      input_artifacts = ["buildout"]
      version         = "1"

      configuration = {
        ApplicationName                = "${var.api_service_name}-service-deploy"
        DeploymentGroupName            = "${var.api_service_name}-service-deploy-group"
        TaskDefinitionTemplateArtifact = "buildout"
        AppSpecTemplateArtifact        = "buildout"
      }
    }
  }
}
