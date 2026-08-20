variable "additional_ports" {
  type        = list(number)
  description = "Additional TCP ports to allow ingress on, in addition to 443"
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
