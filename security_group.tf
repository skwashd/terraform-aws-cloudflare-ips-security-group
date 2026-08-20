locals {
  name = var.name == "" ? "CloudflareIngress-${var.vpc_id}" : var.name

  # Cloudflare terminates TLS, so 443/tcp is always required. Numbers, not
  # strings, so from_port/to_port need no coercion; toset() absorbs a caller
  # who repeats 443 in additional_ports.
  ports = toset(concat([443], var.additional_ports))

  ranges = {
    ipv4 = data.cloudflare_ip_ranges.this.ipv4_cidrs
    ipv6 = data.cloudflare_ip_ranges.this.ipv6_cidrs
  }

  # setproduct() is the documented idiom for building a for_each map from every
  # combination of two collections. The "<cidr>:<port>" key format is part of
  # this module's state contract -- changing it destroys and recreates every
  # rule for every existing user. Do not tidy it.
  ipv4_rules = {
    for pair in setproduct(local.ranges.ipv4, local.ports) :
    "${pair[0]}:${pair[1]}" => {
      cidr        = pair[0]
      port        = pair[1]
      description = "Allow ingress from Cloudflare (${pair[0]}) on port ${pair[1]}"
    }
  }

  ipv6_rules = {
    for pair in setproduct(local.ranges.ipv6, local.ports) :
    "${pair[0]}:${pair[1]}" => {
      cidr        = pair[0]
      port        = pair[1]
      description = "Allow ingress from Cloudflare (${pair[0]}) on port ${pair[1]}"
    }
  }
}

resource "aws_security_group" "this" {
  name        = local.name
  description = "Cloudflare Source IPs for ${var.vpc_id}"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = local.name })

  lifecycle {
    create_before_destroy = true
  }
}

check "rule_quota" {
  assert {
    condition = length(local.ipv4_rules) + length(local.ipv6_rules) <= 60
    error_message = format(
      "This configuration creates %d rules, which exceeds the default AWS quota of 60 rules per security group. Cloudflare publishes ~22 ranges, so each port costs ~22 rules. Request a quota increase or reduce additional_ports.",
      length(local.ipv4_rules) + length(local.ipv6_rules)
    )
  }
}

resource "aws_vpc_security_group_ingress_rule" "tcp_ipv4" {
  for_each = local.ipv4_rules

  security_group_id = aws_security_group.this.id
  description       = each.value.description

  cidr_ipv4 = each.value.cidr

  ip_protocol = "tcp"
  from_port   = each.value.port
  to_port     = each.value.port

  tags = merge(var.tags, { Name = "${local.name}-${each.key}" })
}

resource "aws_vpc_security_group_ingress_rule" "tcp_ipv6" {
  for_each = local.ipv6_rules

  security_group_id = aws_security_group.this.id
  description       = each.value.description

  cidr_ipv6 = each.value.cidr

  ip_protocol = "tcp"
  from_port   = each.value.port
  to_port     = each.value.port

  tags = merge(var.tags, { Name = "${local.name}-${each.key}" })
}
