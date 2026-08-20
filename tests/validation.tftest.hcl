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

run "malformed_vpc_id" {
  command = plan

  variables {
    vpc_id = "not-a-vpc-id"
  }

  expect_failures = [var.vpc_id]
}

run "out_of_range_port" {
  command = plan

  variables {
    vpc_id           = "vpc-0a1b2c3d4e5f6a7b8"
    additional_ports = [70000]
  }

  expect_failures = [var.additional_ports]
}
