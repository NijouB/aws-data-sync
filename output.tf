output "s3_location" {
  value = aws_datasync_location_s3.destination.arn
}

output "datasync_task" {
  value = aws_datasync_task.example.arn
}
