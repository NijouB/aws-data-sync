data "aws_iam_role" "source_account_role" {
  provider = aws.source_account
  name     = var.source_account_role
}


// Source location as S3 Bucket and subdirectory
data "aws_s3_bucket" "source" {
  bucket   = local.source_bucket
  provider = aws.source_account
}

// Destination location as S3 Bucket and subdirectory
data "aws_s3_bucket" "destination" {
  bucket   = local.destination_bucket
  provider = aws.destination_account
}
