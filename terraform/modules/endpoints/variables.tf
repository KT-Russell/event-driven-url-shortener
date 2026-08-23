variable "name_prefix" {
  description = "Prefix used for endpoint names."
  type        = string
}
variable "aws_region" {
  description = "AWS region containing the endpoint services."
  type        = string
}
variable "vpc_id" {
  description = "ID of the endpoint VPC."
  type        = string
}
variable "private_subnet_ids" {
  description = "Private subnet IDs for interface endpoints."
  type        = list(string)
}
variable "private_route_table_id" {
  description = "Private route table ID for the S3 gateway endpoint."
  type        = string
}
variable "security_group_id" {
  description = "Security group ID for interface endpoints."
  type        = string
}
variable "tags" {
  description = "Common tags applied to endpoints."
  type        = map(string)
}