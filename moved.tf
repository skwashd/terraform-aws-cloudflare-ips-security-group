# Label renames introduced in 2.0.0. Safe to delete once every consumer has run
# a 2.x apply; keep until 3.0.0.
moved {
  from = aws_vpc_security_group_ingress_rule.ingress_tcp_ipv4
  to   = aws_vpc_security_group_ingress_rule.tcp_ipv4
}

moved {
  from = aws_vpc_security_group_ingress_rule.ingress_tcp_ipv6
  to   = aws_vpc_security_group_ingress_rule.tcp_ipv6
}
