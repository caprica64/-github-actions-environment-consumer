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


data "terraform_remote_state" "bucket" {
  backend = "remote"

  config = {
    organization = "caprica"
    workspaces = {
          name = "GitHub-Actions-Environments-Dev"
    }
  }
}

#TO-DO set up above to Cloud {} and use GitHub env vars. I am considering making it another project similar to this.


provider "aws" {
  region = "us-east-1"
}

data "archive_file" "object" {
  type = "zip"

  source_dir  = "${path.module}/prefix"
  output_path = "${path.module}/object.zip"
}

resource "aws_s3_object" "s3-object" {
  
  bucket = data.terraform_remote_state.bucket.outputs.s3_bucket_name
  #bucket = "github-actions-dev-tahr" # <<- Previous hardcoded between different workspaces.

  key    = "object.zip"
  source = data.archive_file.object.output_path

  etag = filemd5(data.archive_file.object.output_path)
}