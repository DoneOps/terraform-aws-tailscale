data "aws_ami" "amazon2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2*-gp2"]
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
  depends_on = [tailscale_tailnet_key.bastion_key]
  ami                         = data.aws_ami.amazon2.id
  instance_type               = "t4g.micro"
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id
  user_data_replace_on_change = true
  source_dest_check           = false

  vpc_security_group_ids = [aws_security_group.allow_bastion_ssh_sg.id]

  user_data = templatefile(
    "${path.module}/cloud-init-userdata.tpl",
    {
      auth_key          = tailscale_tailnet_key.bastion_key.key
      advertised_routes = join(",", var.advertised_routes)
      hostname          = "bastion-${var.name}"
      accept_dns        = var.accept_dns
    }
  )
  credit_specification {
    cpu_credits = "unlimited"
  }
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

resource "aws_security_group" "allow_bastion_ssh_sg" {
  name        = "allow_bastion_ssh_${var.name}"
  description = "Allow ssh to the bastion host"
  vpc_id      = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_bastion_ssh_${var.name}"
  }
}

module "ebs_kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "3.0.0"

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
  tags = var.tailscale_tags
  # lifecycle {
  #   replace_triggered_by = [
  #     data.aws_ami.amazon2.id
  #   ]
  # }
}
