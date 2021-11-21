resource "aws_security_group" "this" {
  name        = local.name
  description = "Cloudflare Source IPs for ${var.vpc_id}"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Block ingress by default"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["127.0.0.1/32"]
    ipv6_cidr_blocks = ["::1/128"]
  }
  egress {
    description      = "Block egress by default"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["127.0.0.1/32"]
    ipv6_cidr_blocks = ["::1/128"]
  }

  tags = var.tags
}

resource "aws_security_group_rule" "ingress_tcp" {
  for_each          = local.ports
  type              = "ingress"
  from_port         = each.key
  to_port           = each.key
  protocol          = "tcp"
  cidr_blocks       = toset(data.cloudflare_ip_ranges.cloudflare.ipv4_cidr_blocks)
  ipv6_cidr_blocks  = toset(data.cloudflare_ip_ranges.cloudflare.ipv6_cidr_blocks)
  security_group_id = aws_security_group.this.id
}
