variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnet_id" {
  type        = string
  description = "Subnet in which to dpeloy the ec2 instance"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
  default     = {}
}

# variable "bastion_ip_allowlist_ipv4" {
#   type        = list(string)
#   description = "List of IPv4 CIDR blocks which can access the Bastion proxy"
#   default     = []
# }

# variable "bastion_ip_allowlist_ipv6" {
#   type        = list(string)
#   description = "List of IPv6 CIDR blocks which can access the Bastion proxy"
#   default     = []
# }

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
