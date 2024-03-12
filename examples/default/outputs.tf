output "instance_eip" {
  value = module.bastion_host.instance_eip.public_ip
}

output "instance_public_key" {
  value = module.bastion_host.bastion_public_key
}

output "instance_private_key" {
  value     = module.bastion_host.bastion_private_key
  sensitive = true
}
