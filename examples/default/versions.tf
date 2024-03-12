terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.67.0"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.15.0"
    }
  }
  required_version = "1.5.7"
}
