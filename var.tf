variable "source_s3_path" {
  type        = string
  description = "S3 source path"
  validation {
    condition     = can(regex("^s3:\\/\\/([^\\/]+)(\\/|\\/(.*?([^\\/]+))){0,}$", var.source_s3_path))
    error_message = "Provide a valid s3 path: s3://bucket/key"
  }
  default = "s3://account1-my-precious-bucket123/dir1/"
}

variable "destination_s3_path" {
  type        = string
  description = "S3 destination path"
  validation {
    condition     = can(regex("^s3:\\/\\/([^\\/]+)(\\/|\\/(.*?([^\\/]+))){0,}$", var.destination_s3_path))
    error_message = "Provide a valid s3 path: s3://bucket/key"
  }
  default = "s3://account2-my-precious-bucket123/dir1/"
}

variable "datasync_task_name" {
  type        = string
  description = "Name of the datasync task"
  default     = "migration-task"
}

variable "destination_account" {
  type        = string
  description = "The destination account where is the S3 bucket that you're transferring data to"
  default     = "1234567890"
}
variable "destination_account_profile" {
  type        = string
  description = "Profile of the destination account"
  default     = "admin123"
}
variable "destination_account_role" {
  type        = string
  description = "Role of the destination account"
  default     = "alias1@admin"
}

variable "source_account" {
  type        = string
  description = "The source account where is the S3 bucket that you're transferring data from"
  default     = "112345678900"
}
variable "source_account_profile" {
  type        = string
  description = "Profile of the source account to use DataSync"
  default     = "admin"
}
variable "source_account_role" {
  type        = string
  description = "Role of the source account to use DataSync"
  default     = "alias2@admin"
}
