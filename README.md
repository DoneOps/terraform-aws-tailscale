# terraform-aws-tailscale
terraform module for a tailscle host

Configure your tailscal provider with the following env vars:
```
TAILSCALE_OAUTH_CLIENT_ID
TAILSCALE_OAUTH_CLIENT_SECRET
```
add the following to your provider block:
```hcl
provider "tailscale" {}
```
Ensure the tags passed in to input_tags are valid for the oauth client you created.

This module is currently only tested to run in a public subnet.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.5.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.20 |
| <a name="requirement_tailscale"></a> [tailscale](#requirement\_tailscale) | 0.15.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.40.0 |
| <a name="provider_tailscale"></a> [tailscale](#provider\_tailscale) | 0.15.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ebs_kms_key"></a> [ebs\_kms\_key](#module\_ebs\_kms\_key) | terraform-aws-modules/kms/aws | 2.2.1 |

## Resources

| Name | Type |
|------|------|
| [aws_instance.bastion_host_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.allow_bastion_ssh_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [tailscale_tailnet_key.bastion_key](https://registry.terraform.io/providers/tailscale/tailscale/0.15.0/docs/resources/tailnet_key) | resource |
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
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet in which to dpeloy the ec2 instance | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_incoming_security_group_id"></a> [incoming\_security\_group\_id](#output\_incoming\_security\_group\_id) | Security group ID for bastion sg |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | n/a |
<!-- END_TF_DOCS -->
