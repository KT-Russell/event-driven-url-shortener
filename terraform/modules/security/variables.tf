variable "vpc_cidr" {
  description = "vpc cidr range"
  type        = string
}

variable "name_prefix" {
  description = "prefix used for security group names"
  type        = string
}

variable "tags" {
  description = "Common tags applied to security groups resources"
  type        = map(string)
}



variable "vpc_id" {
  description = "ID of the VPC where security groups are created"
  type        = string
}

variable "aws_region" {
  description = "AWS region used to locate AWS-managed prefix lists"
  type        = string
}
