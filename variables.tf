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

variable "advertised_routes" {
  type        = list(string)
  description = "List of advertised routes for the bastion host"
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
