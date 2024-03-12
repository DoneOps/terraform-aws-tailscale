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
  ami                         = data.aws_ami.amazon2.id
  instance_type               = "t4g.micro"
  associate_public_ip_address = false
  # key_name                    = aws_key_pair.bastion.key_name
  subnet_id                   = var.subnet_id
  user_data_replace_on_change = true
  source_dest_check           = false
  # iam_instance_profile        = aws_iam_instance_profile.bastion_ec2_instance_profile.id

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
    http_endpoint               = "disabled"
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

  # ingress {
  #   description      = "SSH from IPs"
  #   from_port        = 22
  #   to_port          = 22
  #   protocol         = "tcp"
  #   cidr_blocks      = var.bastion_ip_allowlist_ipv4
  #   ipv6_cidr_blocks = var.bastion_ip_allowlist_ipv6
  # }

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
  version = "2.2.1"

  description           = "key to encrypt bastion ebs volumes"
  enable_default_policy = true
  key_owners            = [data.aws_iam_session_context.current.issuer_arn]

  # Aliases
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
  lifecycle {
    replace_triggered_by = [
      data.aws_ami.amazon2.id
    ]
  }
}