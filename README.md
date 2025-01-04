# Cloudflare Source IPs AWS Security Group Ingress

This terraform module populates an AWS security group ingress rules with Cloudflare source IPs. By default module only allows access for 443/tcp (https), but additional ports can be added.

## Example

To include this model in your project you can use the following definition:

```hcl2
module "cloudflare_ips" {
  source  = "skwashd/cloudflare-ips-security-group/aws"
  version = "1.1.0"

  vpc_id = aws_vpc.id

  tags = var.tags
}

# ...

resource "aws_lb" "my_app" {
  name = "app-${var.tags["Environment"]}"

  load_balancer_type = "application"
  security_groups    = [module.cloudflare_ips.security_group.id, aws_security_group.alb.id] # etc

  # ...
}
```

This will create the security group and attach it to your load balancer.

## API Token

The Cloudflare provider requires an API token. 

If you already use the Cloudflare provider in your project, you don't need to do anything. Your existing token will work.

If you only need to fetch the IPs, then you don't need to generate a real token. The IP lookup doesn't use the token to fetch the values. In your pipeline set the `CLOUDFLARE_API_TOKEN` using `export CLOUDFLARE_API_TOKEN="YQSn-xWAQiiEh9qM58wZNnyQS7FUdoqGIUAbrh7T"` or the equivelant in your deployment tool of choice. This invalid token that passes validation [lifted from Cloudflare docs](https://developers.cloudflare.com/api/).

## Generated Docs

<!-- BEGIN_TF_DOCS -->


----

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0, < 6.0.0 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | >= 4.0.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0, < 6.0.0 |
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | >= 4.0.0, < 5.0.0 |

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
| [aws_vpc_security_group_ingress_rule.ingress_tcp_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.ingress_tcp_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [cloudflare_ip_ranges.cloudflare](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/ip_ranges) | data source |
<!-- END_TF_DOCS -->
