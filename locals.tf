locals {
  # Split source and destination paths into bucket
  source_path_parts      = split("/", var.source_s3_path)
  destination_path_parts = split("/", var.destination_s3_path)
  source_bucket          = local.source_path_parts[2]
  destination_bucket     = local.destination_path_parts[2]
  # and subdirectories
  source_key               = join("/", slice(local.source_path_parts, 3, length(local.source_path_parts)))
  source_subdirectory      = "/${local.source_key}"
  destination_key          = join("/", slice(local.destination_path_parts, 3, length(local.destination_path_parts)))
  destination_subdirectory = "/${local.destination_key}"
}
