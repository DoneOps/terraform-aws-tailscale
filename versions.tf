terraform {
  required_version = ">=1.5.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.20"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.16.1"
    }
  }
}
