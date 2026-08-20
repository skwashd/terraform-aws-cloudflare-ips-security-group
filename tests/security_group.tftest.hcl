# override_during = plan requires Terraform >= 1.11. This is a CI/contributor
# requirement only -- `terraform test` still enforces the module's own
# `required_version` floor (>= 1.0.0), which is unaffected.

mock_provider "aws" {
  override_during = plan
}

mock_provider "cloudflare" {
  override_during = plan

  mock_data "cloudflare_ip_ranges" {
    defaults = {
      ipv4_cidrs = [
        "192.0.2.0/24",
        "198.51.100.0/24",
        "203.0.113.0/24",
      ]
      ipv6_cidrs = [
        "2001:db8::/32",
        "2001:db8:1::/48",
      ]
    }
  }
}

variables {
  vpc_id = "vpc-0a1b2c3d4e5f6a7b8"
}

run "defaults" {
  command = plan

  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.ingress_tcp_ipv4) == 3
    error_message = "Expected 3 IPv4 ingress rules (one per fixture CIDR) with default additional_ports"
  }

  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.ingress_tcp_ipv6) == 2
    error_message = "Expected 2 IPv6 ingress rules (one per fixture CIDR) with default additional_ports"
  }

  assert {
    condition     = contains(keys(aws_vpc_security_group_ingress_rule.ingress_tcp_ipv4), "192.0.2.0/24:443")
    error_message = "Expected IPv4 rule keyed \"192.0.2.0/24:443\" to exist"
  }

  assert {
    condition     = contains(keys(aws_vpc_security_group_ingress_rule.ingress_tcp_ipv6), "2001:db8::/32:443")
    error_message = "Expected IPv6 rule keyed \"2001:db8::/32:443\" to exist -- guards against splitting a key on \":\""
  }

  assert {
    condition = alltrue([
      for r in aws_vpc_security_group_ingress_rule.ingress_tcp_ipv4 :
      r.ip_protocol == "tcp" && r.from_port == 443 && r.to_port == 443
    ])
    error_message = "Every default IPv4 rule must be tcp/443"
  }

  assert {
    condition = alltrue([
      for r in aws_vpc_security_group_ingress_rule.ingress_tcp_ipv6 :
      r.ip_protocol == "tcp" && r.from_port == 443 && r.to_port == 443
    ])
    error_message = "Every default IPv6 rule must be tcp/443"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.ingress_tcp_ipv4["192.0.2.0/24:443"].description == "Allow ingress from Cloudflare (192.0.2.0/24) on port 443"
    error_message = "Rule description text changed -- this is a silent rewrite of all ~22 rules for every existing user"
  }
}

run "additional_ports_regression" {
  command = plan

  variables {
    additional_ports = [8080, 8443]
  }

  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.ingress_tcp_ipv4) == 9
    error_message = "Expected 9 IPv4 ingress rules (3 CIDRs x 3 ports)"
  }

  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.ingress_tcp_ipv6) == 6
    error_message = "Expected 6 IPv6 ingress rules (2 CIDRs x 3 ports)"
  }

  assert {
    condition     = length([for k in keys(aws_vpc_security_group_ingress_rule.ingress_tcp_ipv4) : k if endswith(k, ":443")]) == 3
    error_message = "Regression for bug 1: expected exactly 3 IPv4 rules on port 443 (one per CIDR) -- additional_ports must not remove port 443"
  }

  assert {
    condition     = toset([for r in aws_vpc_security_group_ingress_rule.ingress_tcp_ipv4 : r.from_port]) == toset([443, 8080, 8443])
    error_message = "Regression for bug 1: expected from_port set {443, 8080, 8443}"
  }
}

run "additional_ports_duplicate_443" {
  command = plan

  variables {
    additional_ports = [443]
  }

  assert {
    condition     = length(aws_vpc_security_group_ingress_rule.ingress_tcp_ipv4) == 3
    error_message = "toset() must de-dupe a caller-supplied 443 in additional_ports, not error or double the rule count"
  }
}

run "default_name" {
  command = plan

  assert {
    condition     = aws_security_group.this.name == "CloudflareIngress-vpc-0a1b2c3d4e5f6a7b8"
    error_message = "Default security group name must be CloudflareIngress-<vpc_id>"
  }
}

run "custom_name" {
  command = plan

  variables {
    name = "my-custom-sg"
  }

  assert {
    condition     = aws_security_group.this.name == "my-custom-sg"
    error_message = "A caller-supplied name must be used verbatim"
  }

  assert {
    condition     = aws_security_group.this.tags["Name"] == "my-custom-sg"
    error_message = "The Name tag must match the caller-supplied name"
  }
}

run "tags_propagate" {
  command = plan

  variables {
    tags = {
      Team = "engineering"
    }
  }

  assert {
    condition     = aws_security_group.this.tags["Team"] == "engineering"
    error_message = "var.tags must reach the security group"
  }

  assert {
    condition = alltrue([
      for r in aws_vpc_security_group_ingress_rule.ingress_tcp_ipv4 : r.tags["Team"] == "engineering"
    ])
    error_message = "var.tags must reach every IPv4 ingress rule"
  }

  assert {
    condition = alltrue([
      for r in aws_vpc_security_group_ingress_rule.ingress_tcp_ipv6 : r.tags["Team"] == "engineering"
    ])
    error_message = "var.tags must reach every IPv6 ingress rule"
  }
}
