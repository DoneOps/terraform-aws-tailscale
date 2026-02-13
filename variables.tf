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
  description = "List of advertised routes for the bastion host (only used in subnet-router mode)"
  default     = []
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
    condition     = alltrue([for tag in var.tailscale_tags : can(regex("^tag:", tag))])
    error_message = "All items in the tailscale_tags list must be prefixed with 'tag:'."
  }
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for the Tailscale node"
  default     = "t4g.micro"
}

variable "security_group_id" {
  type        = string
  description = "Optional existing security group ID. If provided, skips SG creation."
  default     = null
}

variable "security_group_name" {
  type        = string
  description = "Name for the security group. Defaults to 'tailscale-{name}'."
  default     = null
}
