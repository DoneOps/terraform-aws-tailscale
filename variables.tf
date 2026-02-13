variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnet_id" {
  type        = string
  description = "Subnet in which to deploy the EC2 instance"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "name" {
  type        = string
  description = "Stack name to use in resource creation"
}

variable "mode" {
  description = "Tailscale mode: 'subnet-router' or 'app-connector'"
  type        = string
  default     = "subnet-router"

  validation {
    condition     = contains(["subnet-router", "app-connector"], var.mode)
    error_message = "Mode must be 'subnet-router' or 'app-connector'."
  }
}

variable "advertised_routes" {
  type        = list(string)
  description = "List of advertised routes for the bastion host (required for subnet-router mode)"
  default     = []

  validation {
    condition     = alltrue([for route in var.advertised_routes : can(cidrhost(route, 0))])
    error_message = "All items in advertised_routes must be valid CIDR blocks (e.g., '10.0.0.0/16')."
  }
}

variable "accept_dns" {
  type        = bool
  description = "For EC2 instances it is generally best to let Amazon handle the DNS configuration, not have Tailscale override it"
  default     = false

}

variable "tailscale_tags" {
  type        = list(string)
  description = "List of tags to apply to the Tailscale node"
  default     = ["tag:bastion"]

  validation {
    condition     = length(var.tailscale_tags) > 0 && alltrue([for tag in var.tailscale_tags : can(regex("^tag:", tag))])
    error_message = "tailscale_tags must contain at least one tag, and all items must be prefixed with 'tag:'."
  }
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for the Tailscale node. Must be ARM64/Graviton (e.g., t4g, m6g, c6g) since the module uses an arm64 AMI."
  default     = "t4g.micro"
}

variable "security_group_id" {
  type        = string
  description = "Optional existing security group ID. If provided, skips SG creation."
  default     = null

  validation {
    condition     = var.security_group_id == null || can(regex("^sg-[a-f0-9]{8,17}$", var.security_group_id))
    error_message = "security_group_id must be a valid AWS security group ID (e.g., sg-0123456789abcdef0) or null."
  }
}

variable "security_group_name" {
  type        = string
  description = "Name for the created security group. Ignored when security_group_id is provided. Defaults to 'tailscale-{name}'."
  default     = null
}
