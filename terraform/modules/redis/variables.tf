variable "name_prefix" {
  description = "Prefix used when naming Redis resources"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by the ElastiCache subnet group"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group attached to the Redis replication group"
  type        = string
}

variable "node_type" {
  description = "ElastiCache node type used by the Redis replication group"
  type        = string
  default     = "cache.t4g.micro"
}

variable "tags" {
  description = "Common tags applied to Redis resources"
  type        = map(string)
  default     = {}
}