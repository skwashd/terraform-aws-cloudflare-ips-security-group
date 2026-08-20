output "security_group" {
  value       = aws_security_group.this
  description = "DEPRECATED: use security_group_id, security_group_arn or security_group_name instead. Will be removed in 3.0.0. AWS security group containing ingress rules for Cloudflare services"
}

output "security_group_id" {
  value       = aws_security_group.this.id
  description = "ID of the security group"
}

output "security_group_arn" {
  value       = aws_security_group.this.arn
  description = "ARN of the security group"
}

output "security_group_name" {
  value       = aws_security_group.this.name
  description = "Name of the security group"
}

output "security_group_rule_ids" {
  value = concat(
    [for r in aws_vpc_security_group_ingress_rule.tcp_ipv4 : r.id],
    [for r in aws_vpc_security_group_ingress_rule.tcp_ipv6 : r.id],
  )
  description = "IDs of every Cloudflare ingress rule. Useful as a caller-side depends_on target: depends_on = [module.cloudflare_ips]"
}
