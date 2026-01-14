output "incoming_security_group_id" {
  description = "Security group ID used by the Tailscale instance"
  value       = local.effective_security_group_id
}

output "instance_id" {
  description = "EC2 instance ID of the bastion host"
  value       = aws_instance.bastion_host_ec2.id
}
