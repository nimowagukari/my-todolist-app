terraform {
  required_version = "1.7.1"
  backend "s3" {
    # S3 bucket must be specified with -backend-config option.
    key    = "tfstate.d/my-todolist-app/backend/express-prisma/terraform.tfstate.json"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.30.0"
    }
  }
}
