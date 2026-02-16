# terraform-aws-tailscale

Terraform module for deploying a Tailscale node on AWS EC2 as either a **subnet router** or **app connector**.

## Overview

This module creates an EC2 instance that connects to your Tailscale network. It supports two modes:

- **Subnet Router** (default): Advertises IP routes to your VPC, allowing Tailscale devices to access private resources by IP address
- **App Connector**: Advertises itself as a connector for DNS-based routing, ideal for environments with overlapping CIDRs

**What gets created:**
- EC2 instance (ARM64, t4g.micro by default) running Tailscale
- Security group (egress-only, ingress handled by Tailscale)
- KMS key for EBS encryption
- Tailscale auth key for automatic node registration

## Prerequisites

1. **Tailscale account** with admin access
2. **OAuth client** created in Tailscale admin console with:
   - `devices:write` scope (to register the node)
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

### Subnet Router Mode (Default)

Use subnet router mode when you want to expose VPC resources by IP address. Best for single environments or when CIDRs don't overlap.

```hcl
module "tailscale_bastion" {
  source  = "DoneOps/tailscale/aws"
  version = "0.2.0"

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

### App Connector Mode

Use app connector mode when you have multiple environments with overlapping VPC CIDRs. Routes traffic by DNS name instead of IP address.

```hcl
module "tailscale_connector" {
  source  = "DoneOps/tailscale/aws"
  version = "0.2.0"

  name           = "staging"
  mode           = "app-connector"
  vpc_id         = "vpc-0123456789abcdef0"
  subnet_id      = "subnet-0123456789abcdef0"
  tailscale_tags = ["tag:staging-connector"]

  tags = {
    Environment = "staging"
  }
}
```

**Important:** App connector domains are configured in your Tailscale ACL policy, not in Terraform. See [ACL Configuration](#app-connector-acl-configuration) below.

## How It Works

### Subnet Router
1. The module launches an Amazon Linux 2023 EC2 instance in your specified subnet
2. On boot, the instance installs Tailscale and authenticates using the generated auth key
3. The instance advertises your VPC CIDR ranges to the Tailscale network
4. Devices on your Tailscale network can route traffic to your VPC through this node

### App Connector
1. The module launches an EC2 instance configured as an app connector
2. The instance registers with Tailscale using `--advertise-connector`
3. Domains are configured in your Tailscale ACL policy (Admin Console)
4. The connector resolves DNS names and automatically advertises routes for discovered IPs
5. Traffic for configured domains flows through the connector

**Note:** This module requires a public subnet with internet access. The node needs outbound connectivity to reach Tailscale's coordination servers.

## App Connector ACL Configuration

After deploying in app-connector mode, configure your Tailscale ACL policy:

### 1. Tag Owners

```json
"tagOwners": {
  "tag:staging-connector": ["autogroup:admin"]
}
```

### 2. Auto-Approvers

```json
"autoApprovers": {
  "routes": {
    "0.0.0.0/0": ["tag:staging-connector"],
    "::/0": ["tag:staging-connector"]
  }
}
```

### 3. App Configuration

```json
"nodeAttrs": [{
  "target": ["tag:staging-connector"],
  "app": {
    "tailscale.com/app-connectors": [{
      "name": "AWS Staging",
      "connectors": ["tag:staging-connector"],
      "domains": [
        "*.us-east-1.rds.amazonaws.com",
        "*.us-east-1.redshift.amazonaws.com",
        "*.us-east-1.es.amazonaws.com",
        "*.elasticache.amazonaws.com"
      ]
    }]
  }
}]
```

## Subnet Router vs App Connector

| Feature | Subnet Router | App Connector |
|---------|---------------|---------------|
| Routing | By IP/CIDR | By DNS name |
| Overlapping CIDRs | Causes conflicts | Works fine |
| Configuration | Terraform only | Terraform + ACL policy |
| Access granularity | IP ranges | Specific domains |
| Best for | Single environment | Multi-environment |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.5.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.20 |
| <a name="requirement_tailscale"></a> [tailscale](#requirement\_tailscale) | >= 0.18.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.40.0 |
| <a name="provider_tailscale"></a> [tailscale](#provider\_tailscale) | 0.15.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ebs_kms_key"></a> [ebs\_kms\_key](#module\_ebs\_kms\_key) | terraform-aws-modules/kms/aws | 4.2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_instance.bastion_host_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.allow_bastion_ssh_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [tailscale_tailnet_key.bastion_key](https://registry.terraform.io/providers/tailscale/tailscale/latest/docs/resources/tailnet_key) | resource |
| [aws_ami.amazon2023](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_session_context.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_session_context) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accept_dns"></a> [accept\_dns](#input\_accept\_dns) | For EC2 instances it is generally best to let Amazon handle the DNS configuration, not have Tailscale override it | `bool` | `false` | no |
| <a name="input_advertised_routes"></a> [advertised\_routes](#input\_advertised\_routes) | List of advertised routes for the bastion host (required for subnet-router mode) | `list(string)` | `[]` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Whether to create a security group. Set to false and provide security\_group\_id to use an existing one. | `bool` | `true` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type for the Tailscale node. Must be ARM64/Graviton (e.g., t4g, m6g, c6g) since the module uses an arm64 AMI. | `string` | `"t4g.micro"` | no |
| <a name="input_mode"></a> [mode](#input\_mode) | Tailscale mode: 'subnet-router' or 'app-connector' | `string` | `"subnet-router"` | no |
| <a name="input_name"></a> [name](#input\_name) | Stack name to use in resource creation | `string` | n/a | yes |
| <a name="input_security_group_id"></a> [security\_group\_id](#input\_security\_group\_id) | Existing security group ID to use. Required when create\_security\_group is false. | `string` | `null` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | Name for the created security group. Only used when create\_security\_group is true. Defaults to 'tailscale-{name}'. | `string` | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet in which to deploy the EC2 instance | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_tailscale_tags"></a> [tailscale\_tags](#input\_tailscale\_tags) | List of tags to apply to the Tailscale node | `list(string)` | <pre>[<br/>  "tag:bastion"<br/>]</pre> | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_incoming_security_group_id"></a> [incoming\_security\_group\_id](#output\_incoming\_security\_group\_id) | Security group ID used by the Tailscale instance |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | EC2 instance ID of the bastion host |
<!-- END_TF_DOCS -->

## References

- [Tailscale Subnet Routers](https://tailscale.com/kb/1019/subnets)
- [Tailscale App Connectors](https://tailscale.com/kb/1281/app-connectors)
- [App Connector Setup Guide](https://tailscale.com/kb/1342/app-connectors-setup)
