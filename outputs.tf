output "incoming_security_group_id" {
  description = "Security group ID for bastion sg"
  value       = aws_security_group.allow_bastion_ssh_sg.id
}

# output "instance_eip" {
#   value = aws_eip.bastion_host_eip
# }

# output "bastion_private_key" {
#   value     = tls_private_key.bastion.private_key_pem
#   sensitive = true
# }

# output "bastion_public_key" {
#   value = tls_private_key.bastion.public_key_openssh
# }

output "instance_id" {
  value = aws_instance.bastion_host_ec2.id
}
