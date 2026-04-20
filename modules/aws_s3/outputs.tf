output "endpoint" {
  value = try(aws_s3_bucket.this.bucket_domain_name, null)
}

output "queue_url" {
  value = try(aws_sqs_queue.s3_events[0].id, null)
}
