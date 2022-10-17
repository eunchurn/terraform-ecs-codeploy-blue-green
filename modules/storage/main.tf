resource "aws_s3_bucket" "assets" {
  bucket        = "${var.uploads_bucket_prefix}-${var.application_name}-${terraform.workspace}"
  force_destroy = true
  tags = {
    Name        = "${var.application_name}-${terraform.workspace}-s3-assets-bucket"
    Environment = "${var.application_name}-${terraform.workspace}"
  }
}

resource "aws_s3_bucket_acl" "assets_acl" {
  bucket = aws_s3_bucket.assets.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "assets_lifecycle" {
  bucket = aws_s3_bucket.assets.id

  rule {
    id = "uploads"
    transition {
      days          = 90
      storage_class = "ONEZONE_IA"
    }
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "assets_access_block" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
