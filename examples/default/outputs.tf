output "instance_eip" {
  value = module.bastion_host.instance_eip.public_ip
}
