variable "vpc_cidr" {
  description = "vpc cidr range"
  type        = string
}

variable "name_prefix" {
  description = "prefix used for networking resource names"
  type        = string
}

variable "tags" {
  description = "common tags applied to networking resources"
  type        = map(string)
}

variable "aws_availability_zones" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}