variable "additional_ports" {
  type        = list(number)
  description = "Additional TCP ports to allow ingress on, in addition to 443"
  default     = []

  validation {
    condition     = alltrue([for port in var.additional_ports : port >= 1 && port <= 65535])
    error_message = "Each port in additional_ports must be between 1 and 65535."
  }
}

variable "name" {
  type        = string
  description = "The name of the security group"
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "The tags to apply to the security group and rules. A Name key is ignored -- the module always computes its own Name tag."
  default     = {}
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to place the security group within"

  validation {
    condition     = can(regex("^vpc-([0-9a-f]{8}|[0-9a-f]{17})$", var.vpc_id))
    error_message = "vpc_id must be a VPC ID of the form vpc-xxxxxxxx or vpc-xxxxxxxxxxxxxxxxx."
  }
}
