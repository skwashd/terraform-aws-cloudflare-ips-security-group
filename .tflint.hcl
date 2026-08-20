plugin "aws" {
  enabled = true
  version = "0.48.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

plugin "dave-says" {
  enabled = true
  version = "0.4.0"
  source  = "github.com/skwashd/tflint-ruleset-dave-says"
}

plugin "terraform" {
  enabled = true
  preset  = "all"
}

# This module creates one security group and nothing else. There are no subnet
# inputs to derive a VPC from, so vpc_id is the module's entire input contract
# and the vpc_id/subnet_ids mismatch bug class this rule prevents cannot occur.
rule "dave_no_vpc_id_variable" {
  enabled = false
}

# aws_resource_missing_tags is deliberately left off: tags come from var.tags,
# which tflint cannot resolve, so it would false-positive on every resource.
# Enforce it in root modules instead.
