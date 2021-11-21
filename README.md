# Cloudflare Source IPs AWS Security Group Ingress
<!-- BEGIN_TF_DOCS -->
Module populates an AWS security group ingress rules with Cloudflare source IPs. By default module only allows access for 443/tcp (https), but additional ports can be added.

The Cloudflare provider requires an API. The IP lookup doesn't use the token to featch the values. Using `export CLOUDFLARE_API_TOKEN="YQSn-xWAQiiEh9qM58wZNnyQS7FUdoqGIUAbrh7T"` works. This nvalid token that passes validation [lifted from Cloudflare docs](https://developers.cloudflare.com/api/).

----

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.65.0 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | ~> 3.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.65.0 |
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | 3.4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC to place the security group within | `string` | n/a | yes |
| <a name="input_additional_ports"></a> [additional\_ports](#input\_additional\_ports) | Any additional tcp ports that should be addred to the egress rules | `list(number)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the security group | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to apply to the security group and rules | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_security_group"></a> [security\_group](#output\_security\_group) | AWS security group containing ingress rules for Cloudflare services |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.ingress_tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [cloudflare_ip_ranges.cloudflare](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/ip_ranges) | data source |
<!-- END_TF_DOCS -->
