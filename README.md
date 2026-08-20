# Cloudflare Source IPs AWS Security Group Ingress

This terraform module populates an AWS security group ingress rules with Cloudflare source IPs. By default module only allows access for 443/tcp (https), but additional ports can be added.

## Security: allowlisting is not authentication

Cloudflare's published IP ranges are shared by **every** Cloudflare customer, not just you. Any attacker can point their own Cloudflare zone at your origin's public IP or hostname; their proxied requests will arrive from these same ranges and pass this security group, bypassing your WAF rules, rate limits and bot management.

This security group must be paired with one of the following at the origin:

- Authenticated Origin Pulls (mTLS)
- A shared secret header validated by your application
- Cloudflare Tunnel

Allowlisting Cloudflare's IP ranges narrows who can reach your origin's network path. It does not verify that a request actually came through your Cloudflare zone.

## Egress

`aws_security_group.this` is created with no `egress` blocks. The AWS provider treats this as an explicit request to remove the default allow-all egress rule, so a resource with **only** this security group attached will have zero outbound connectivity. The example below is safe because security group rules are additive across every group attached to a resource, and the ALB is expected to have its own egress rule too. If you attach this group on its own to an EC2 instance or ENI, add your own egress rule alongside it.

## Rule quota

Each port adds one ingress rule per Cloudflare IP range: 15 IPv4 ranges + 7 IPv6 ranges = 22 rules per port at the time of writing. The default AWS quota is 60 rules per security group, so more than two ports (default 443 plus one entry in `additional_ports`) requires a quota increase, or the apply will partially fail with `RulesPerSecurityGroupLimitExceeded`.

## Example

To include this module in your project you can use the following definition:

```hcl2
module "cloudflare_ips" {
  source  = "skwashd/cloudflare-ips-security-group/aws"
  version = "2.0.0"

  vpc_id = aws_vpc.this.id

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

If your load balancer must not accept traffic before the Cloudflare ingress rules exist, add `depends_on = [module.cloudflare_ips]` to it. The module does not declare this ordering itself, since a security group with no rules yet fails closed rather than open.

### Changing `vpc_id` on a security group with an explicit `name`

The security group has `create_before_destroy` enabled, which lets Terraform replace it without a `DependencyViolation` when only its `name` changes. If you pass an explicit `name` and change `vpc_id`, the name stays fixed and the replacement will instead fail with `InvalidGroup.Duplicate`, because the new and old groups would collide on name. In that case, rename the group (or remove the explicit `name`) in the same change that moves it to a new VPC.

## UPGRADING from 1.x

Version 2.0.0 changes the module's input/output contract. Nothing here replaces a security group -- `terraform plan` should show only rule-label move notices, no create/destroy -- but each of the following is worth reading before you upgrade:

- **`Name` tag precedence flip.** If you pass a `Name` key inside `var.tags`, the module's computed name now wins instead of your value. Set `var.name` if you need to control the group's name.
- **`tags` is now `map(string)`.** Non-string values (numbers, bools, lists) are now rejected at plan time instead of producing an opaque type-conversion error partway through apply.
- **The `cloudflare` provider floor is now `>= 5.1.0`.** The previously declared `>= 4.0.0` floor was never actually satisfiable against this module's resources, so this only removes support that never worked. The floor is 5.1.0, not 5.0.0, because the `cloudflare_ip_ranges` data source this module depends on was not added until 5.1.0.
- **The `aws` provider floor is now `>= 6.0.0`.** The 5.x series is old enough that it is no longer worth supporting as a floor.
- **`required_version` is now `>= 1.5.0`.**
- **The `security_group` output is deprecated** in favour of `security_group_id`, `security_group_arn` and `security_group_name`. It still works, but will be removed in 3.0.0.
- **The ingress rule resources were renamed** (`ingress_tcp_ipv4` -> `tcp_ipv4`, `ingress_tcp_ipv6` -> `tcp_ipv6`). This is transparent via `moved` blocks -- no action needed, but `terraform plan` will show move notices on your first 2.x plan.

### Accepted lint deviation

The default security group name (`CloudflareIngress-${vpc_id}`) is PascalCase, which violates the `dave_resource_name_kebab` tflint rule. This is an intentional, accepted deviation: `name` is `ForceNew` on `aws_security_group`, so kebab-casing it would replace every existing user's security group. It is not going to change.

## API Token

The Cloudflare provider requires an API token. 

If you already use the Cloudflare provider in your project, you don't need to do anything. Your existing token will work.

If you only need to fetch the IPs, then you don't need to generate a real token. The IP lookup doesn't use the token to fetch the values. In your pipeline set the `CLOUDFLARE_API_TOKEN` using `export CLOUDFLARE_API_TOKEN="YQSn-xWAQiiEh9qM58wZNnyQS7FUdoqGIUAbrh7T"` or the equivalent in your deployment tool of choice. This invalid token that passes validation [lifted from Cloudflare docs](https://developers.cloudflare.com/api/).

## Generated Docs

<!-- BEGIN_TF_DOCS -->


----

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0, < 7.0.0 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | >= 5.1.0, < 6.0.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0.0, < 7.0.0 |
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | >= 5.1.0, < 6.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC to place the security group within | `string` | n/a | yes |
| <a name="input_additional_ports"></a> [additional\_ports](#input\_additional\_ports) | Additional TCP ports to allow ingress on, in addition to 443 | `list(number)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the security group | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to apply to the security group and rules. A Name key is ignored -- the module always computes its own Name tag. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_security_group"></a> [security\_group](#output\_security\_group) | DEPRECATED: use security\_group\_id, security\_group\_arn or security\_group\_name instead. Will be removed in 3.0.0. AWS security group containing ingress rules for Cloudflare services |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | ARN of the security group |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group |
| <a name="output_security_group_name"></a> [security\_group\_name](#output\_security\_group\_name) | Name of the security group |
| <a name="output_security_group_rule_ids"></a> [security\_group\_rule\_ids](#output\_security\_group\_rule\_ids) | IDs of every Cloudflare ingress rule. Useful as a caller-side depends\_on target: depends\_on = [module.cloudflare\_ips] |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_ingress_rule.tcp_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.tcp_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [cloudflare_ip_ranges.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/ip_ranges) | data source |
<!-- END_TF_DOCS -->
