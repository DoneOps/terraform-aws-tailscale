module "bastion_host" {
  source            = "../../"
  name              = "foo"
  vpc_id            = data.aws_vpc.default.id
  subnet_id         = data.aws_subnets.default.ids[0]
  advertised_routes = data.aws_vpc.default.cidr_block
}
