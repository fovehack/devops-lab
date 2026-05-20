output "bucket_name" {
  value       = aws_s3_bucket.mi_bucket_local.id
  description = "El nombre del bucket S3 creado en LocalStack"
}