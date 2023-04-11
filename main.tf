# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "4.52.0"
#     }
#     random = {
#       source  = "hashicorp/random"
#       version = "3.4.3"
#     }
#   }
#   required_version = ">= 1.1.0"
# 
#   cloud {
#     organization = "caprica"
# 
#     workspaces {
#       name = "GitHub-Actions-Environments-dev"
#     }
#   }
# }

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
  required_version = ">= 1.1.0"
  
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "caprica"

    workspaces {
      prefix = "GitHub-Actions-Environments-consumer-"
    }
  }
}


#TO-DO set up above to Cloud {} and use GitHub env vars


provider "aws" {
  region = "us-east-1"
}

resource "random_pet" "random_bucket_name" {
  prefix = "github-actions-${var.environment}"
  length = 1
}

resource "aws_s3_object" "s3-object" {
  bucket = "github-actions-dev-tahr" ##TODO < remove hardcoded and use import from another state #aws_s3_bucket.s3_bucket.id

  key    = "object.txt"
  source = data.archive_file.lambda-handle-inventory.output_path

  etag = filemd5(data.archive_file.lambda-handle-inventory.output_path)
}