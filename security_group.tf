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

resource "aws_vpc_security_group_ingress_rule" "ingress_tcp" {
  for_each = local.ports

  security_group_id = aws_security_group.this.id
  description       = "Allow ingress from Cloudflare on port ${each.key}"

  cidr_ipv4 = toset(data.cloudflare_ip_ranges.cloudflare.ipv4_cidr_blocks)
  cidr_ipv6 = toset(data.cloudflare_ip_ranges.cloudflare.ipv6_cidr_blocks)

  ip_protocol = "tcp"
  from_port   = each.key
  to_port     = each.key
}
