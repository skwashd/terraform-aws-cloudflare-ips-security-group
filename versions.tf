terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.71.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.9.1"
    }
  }
}
