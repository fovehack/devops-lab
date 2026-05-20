terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  region                      = "us-east-1"

  # Estas tres líneas evitan que Terraform intente validar las credenciales contra la nube real
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  # El truco principal: Redirigir las llamadas de S3 a LocalStack
  endpoints {
    s3 = "http://localhost:4566"
  }
}