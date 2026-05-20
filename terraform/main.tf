resource "aws_s3_bucket" "mi_bucket_local" {
  bucket = "terraform-localstack-bucket"

  tags = {
    Environment = "Local-Devops"
    ManagedBy   = "Terraform"
  }
}

# En AWS real, las URLs de S3 usan subdominios (bucket.s3.amazonaws.com). 
# En LocalStack necesitamos forzar el estilo de ruta (localhost:4566/bucket)
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.mi_bucket_local.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}