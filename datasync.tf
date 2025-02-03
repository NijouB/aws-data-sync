/**
* Required permissions for your source account
**/
resource "aws_iam_role_policy" "datasync_permissions_delete_me" {
  name     = "datasync_permissions_delete_me"
  provider = aws.source_account
  role     = data.aws_iam_role.source_account_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:CreatePolicy",
          "iam:PassRole",
          "datasync:DescribeTaskExecution",
          "iam:CreateRole",
          "iam:AttachRolePolicy",
          "s3:ListBucket",
          "datasync:CancelTaskExecution",
          "s3:GetBucketLocation",
          "s3:GetObject"
        ],
        "Resource" : [
          "arn:aws:datasync:*:${var.source_account}:task/*/execution/*",
          data.aws_iam_role.source_account_role.arn,
          "arn:aws:s3:::${local.source_bucket}",
          "arn:aws:s3:::${local.source_bucket}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "datasync:CreateTask",
          "datasync:DescribeTask",
          "datasync:DescribeLocationS3",
          "datasync:StartTaskExecution"
        ],
        "Resource" : [
          "arn:aws:datasync:*:${var.source_account}:location/*",
          "arn:aws:datasync:*:${var.source_account}:task/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "datasync:CreateLocationS3",
          "s3:ListAllMyBuckets",
          "datasync:ListLocations",
          "datasync:ListTaskExecutions",
          "iam:ListRoles",
          "datasync:ListTasks"
        ],
        "Resource" : "*"
      }
    ]
  })
}


/**
* In your source account, create an IAM role for DataSync
**/
resource "aws_iam_policy" "source_datasync_storage_access_policy" {
  name     = "source_datasync_storage_ap_${var.datasync_task_name}"
  provider = aws.source_account

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads"
        ],
        Effect : "Allow",
        Resource : [
          "arn:aws:s3:::${local.source_bucket}",
          "arn:aws:s3:::${local.destination_bucket}"
        ]
      },
      {
        Action : [
          "s3:AbortMultipartUpload",
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:ListMultipartUploadParts",
          "s3:PutObjectTagging",
          "s3:GetObjectTagging",
          "s3:PutObject"
        ],
        Effect : "Allow",
        Resource : [
          "arn:aws:s3:::${local.source_bucket}/*",
          "arn:aws:s3:::${local.destination_bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "source_datasync_bucket_access_role" {
  provider            = aws.source_account
  name                = "source_datasync_bucket_ar_${var.datasync_task_name}"
  managed_policy_arns = [aws_iam_policy.source_datasync_storage_access_policy.arn]
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "datasync.amazonaws.com"
      },
      "Action" : "sts:AssumeRole"
    }]
  })
}


/**
* In your source account, create a DataSync source location
**/
resource "aws_datasync_location_s3" "source" {
  provider      = aws.source_account
  s3_bucket_arn = data.aws_s3_bucket.source.arn
  subdirectory  = local.source_subdirectory
  s3_config {
    bucket_access_role_arn = aws_iam_role.source_datasync_bucket_access_role.arn
  }
}


/**
* In your destination account, update your S3 bucket policy
**/
data "aws_iam_policy_document" "allow_access_for_destination_account" {
  statement {
    sid = "DataSyncCreateS3LocationAndTaskAccess"
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.source_datasync_bucket_access_role.arn]
    }
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:GetObjectTagging",
      "s3:PutObjectTagging"
    ]
    resources = [
      "arn:aws:s3:::${local.destination_bucket}",
      "arn:aws:s3:::${local.destination_bucket}/*"
    ]
  }
  statement {
    sid = "DataSyncCreateS3Location"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.source_account}:role/${var.source_account_role}"]
    }
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${local.destination_bucket}"
    ]
  }
}

resource "aws_s3_bucket_policy" "allow_access_for_destination_account" {
  provider = aws.destination_account
  bucket   = data.aws_s3_bucket.destination.id
  policy   = data.aws_iam_policy_document.allow_access_for_destination_account.json
}


/**
* In your source account, create a DataSync destination location
**/
resource "aws_datasync_location_s3" "destination" {
  provider      = aws.source_account
  s3_bucket_arn = data.aws_s3_bucket.destination.arn
  subdirectory  = local.destination_subdirectory
  s3_config {
    bucket_access_role_arn = aws_iam_role.source_datasync_bucket_access_role.arn
  }
}


/**
* In your source account, create and start your DataSync transfer task
**/
resource "aws_datasync_task" "example" {
  provider                 = aws.source_account
  destination_location_arn = aws_datasync_location_s3.destination.arn
  source_location_arn      = aws_datasync_location_s3.source.arn
  name                     = var.datasync_task_name
}
