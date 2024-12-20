terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0.0"
    }
  }
}
