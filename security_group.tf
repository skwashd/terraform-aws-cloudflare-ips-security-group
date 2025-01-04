resource "aws_security_group" "this" {
  name        = local.name
  description = "Cloudflare Source IPs for ${var.vpc_id}"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      Name = local.name
    },
    var.tags
  )
}

resource "aws_vpc_security_group_ingress_rule" "ingress_tcp_ipv4" {
  for_each = local.ipv4_rules

  security_group_id = aws_security_group.this.id
  description       = each.value.description

  cidr_ipv4 = each.value.cidr

  ip_protocol = "tcp"
  from_port   = each.value.port
  to_port     = each.value.port
}

resource "aws_vpc_security_group_ingress_rule" "ingress_tcp_ipv6" {
  for_each = local.ipv6_rules

  security_group_id = aws_security_group.this.id
  description       = each.value.description

  cidr_ipv6 = each.value.cidr

  ip_protocol = "tcp"
  from_port   = each.value.port
  to_port     = each.value.port
}
