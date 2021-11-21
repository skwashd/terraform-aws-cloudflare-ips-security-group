variable "additional_ports" {
  type        = list(number)
  description = "Any additional tcp ports that should be addred to the egress rules"
  default     = []
}

variable "name" {
  type        = string
  description = "The name of the security group"
  default     = ""
}

variable "tags" {
  type        = map(any)
  description = "The tags to apply to the security group and rules"
  default     = {}
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to place the security group within"
}

locals {
  name  = var.name == "" ? "CloudflareIngress-${var.vpc_id}" : var.name
  ports = toset(length(var.additional_ports) == 0 ? ["443"] : "${concat(["443"], var.additional_ports)}")
}
