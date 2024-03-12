module "bastion_host" {
  source               = "../../"
  name                 = "foo"
  vpc_id               = data.aws_vpc.default.id
  subnet_id            = data.aws_subnets.default.ids[0]
  bastion_ip_allowlist = ["0.0.0.0/0"]
  ssh_public_keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM+tK6Jn6VAQnUoFsU5+70MbrgLxhss6pot9moWCdLav chaosmonkey@doneops.com"
  ]
}
