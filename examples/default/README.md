<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.7.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion_host"></a> [bastion\_host](#module\_bastion\_host) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_subnets.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_eip"></a> [instance\_eip](#output\_instance\_eip) | n/a |
| <a name="output_instance_private_key"></a> [instance\_private\_key](#output\_instance\_private\_key) | n/a |
| <a name="output_instance_public_key"></a> [instance\_public\_key](#output\_instance\_public\_key) | n/a |
<!-- END_TF_DOCS -->