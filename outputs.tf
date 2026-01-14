output "incoming_security_group_id" {
  description = "Security group ID for bastion sg"
  value       = aws_security_group.allow_bastion_ssh_sg.id
}

output "instance_id" {
  description = "EC2 instance ID of the bastion host"
  value       = aws_instance.bastion_host_ec2.id
}
