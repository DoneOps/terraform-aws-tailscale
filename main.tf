locals {
  security_group_name         = var.security_group_name != null ? var.security_group_name : "tailscale-${var.name}"
  effective_security_group_id = var.security_group_id != null ? var.security_group_id : aws_security_group.allow_bastion_ssh_sg[0].id
}

data "aws_ami" "amazon2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  owners = ["137112412989"] # AWS
}

resource "aws_instance" "bastion_host_ec2" {
  depends_on                  = [tailscale_tailnet_key.bastion_key]
  ami                         = data.aws_ami.amazon2023.id
  instance_type               = "t4g.micro"
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id
  user_data_replace_on_change = true
  source_dest_check           = false

  vpc_security_group_ids = [local.effective_security_group_id]

  user_data = templatefile(
    "${path.module}/cloud-init-userdata.tpl",
    {
      auth_key          = tailscale_tailnet_key.bastion_key.key
      advertised_routes = join(",", var.advertised_routes)
      hostname          = "bastion-${var.name}"
      accept_dns        = var.accept_dns
      mode              = var.mode
    }
  )

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
    kms_key_id  = module.ebs_kms_key.key_arn
  }
  metadata_options {
    http_tokens                 = "required"
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }

  tags = {
    Name = "bastion-${var.name}"
  }
}

# Note: Named for historical reasons. Ingress is handled via Tailscale tunnel,
# so no inbound rules are needed. This SG only allows outbound traffic.
resource "aws_security_group" "allow_bastion_ssh_sg" {
  count       = var.security_group_id == null ? 1 : 0
  name        = local.security_group_name
  description = "Security group for Tailscale instance - egress only"
  vpc_id      = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, {
    Name = local.security_group_name
  })
}

module "ebs_kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "4.2.0"

  description           = "key to encrypt bastion ebs volumes"
  enable_default_policy = true
  key_owners            = [data.aws_iam_session_context.current.issuer_arn]

  aliases = ["bastion/${var.name}/ebs"]

  tags = {
    Name = "bastion-${var.name}"
  }
}

resource "tailscale_tailnet_key" "bastion_key" {
  reusable      = true
  ephemeral     = false
  preauthorized = true
  expiry        = 7776000
  description   = "bastion-${var.name}"
  tags          = var.tailscale_tags
}
