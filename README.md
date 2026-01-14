# terraform-aws-tailscale

Terraform module for deploying a Tailscale bastion host on AWS EC2.

## Overview

This module creates an EC2 instance that connects to your Tailscale network and advertises routes to your VPC. This allows you to securely access private AWS resources from any device on your Tailscale network without exposing them to the public internet.

**What gets created:**
- EC2 instance (t4g.micro ARM64) running Tailscale
- Security group (egress-only, ingress handled by Tailscale)
- KMS key for EBS encryption
- Tailscale auth key for automatic node registration

## Prerequisites

1. **Tailscale account** with admin access
2. **OAuth client** created in Tailscale admin console with:
   - `devices:write` scope (to register the bastion)
   - Tags configured that match your `tailscale_tags` variable

## Provider Configuration

Set the following environment variables:

```bash
export TAILSCALE_OAUTH_CLIENT_ID="your-client-id"
export TAILSCALE_OAUTH_CLIENT_SECRET="your-client-secret"
```

Add the provider block to your Terraform configuration:

```hcl
provider "tailscale" {}
```

## Usage

```hcl
module "tailscale_bastion" {
  source  = "DoneOps/tailscale/aws"
  version = "0.1.10"

  name              = "production"
  vpc_id            = "vpc-0123456789abcdef0"
  subnet_id         = "subnet-0123456789abcdef0"
  advertised_routes = ["10.0.0.0/16"]
  tailscale_tags    = ["tag:bastion"]

  tags = {
    Environment = "production"
  }
}
```

## How It Works

1. The module launches an Amazon Linux 2 EC2 instance in your specified subnet
2. On boot, the instance installs Tailscale and authenticates using the generated auth key
3. The instance advertises your VPC CIDR ranges to the Tailscale network
4. Devices on your Tailscale network can now route traffic to your VPC through this bastion

**Note:** This module requires a public subnet with internet access. The bastion needs outbound connectivity to reach Tailscale's coordination servers.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.5.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.20 |
| <a name="requirement_tailscale"></a> [tailscale](#requirement\_tailscale) | 0.25.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.20 |
| <a name="provider_tailscale"></a> [tailscale](#provider\_tailscale) | 0.25.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ebs_kms_key"></a> [ebs\_kms\_key](#module\_ebs\_kms\_key) | terraform-aws-modules/kms/aws | 4.2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_instance.bastion_host_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.allow_bastion_ssh_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [tailscale_tailnet_key.bastion_key](https://registry.terraform.io/providers/tailscale/tailscale/0.25.0/docs/resources/tailnet_key) | resource |
| [aws_ami.amazon2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_session_context.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_session_context) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accept_dns"></a> [accept\_dns](#input\_accept\_dns) | For EC2 instances it is generally best to let Amazon handle the DNS configuration, not have Tailscale override it | `bool` | `false` | no |
| <a name="input_advertised_routes"></a> [advertised\_routes](#input\_advertised\_routes) | List of advertised routes for the bastion host | `list(string)` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Stack name to use in resource creation | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet in which to deploy the EC2 instance | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_tailscale_tags"></a> [tailscale\_tags](#input\_tailscale\_tags) | List of tags to apply to the Tailscale node | `list(string)` | `["tag:bastion"]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_incoming_security_group_id"></a> [incoming\_security\_group\_id](#output\_incoming\_security\_group\_id) | Security group ID for bastion sg |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | EC2 instance ID of the bastion host |
<!-- END_TF_DOCS -->
