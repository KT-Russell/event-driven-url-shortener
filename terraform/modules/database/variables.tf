variable "name_prefix" {
  description = "Prefix used when naming database resources"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by the RDS subnet group"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group attached to the RDS instance"
  type        = string
}

variable "db_name" {
  description = "Name of the PostgreSQL database"
  type        = string
}

variable "db_username" {
  description = "Master username for PostgreSQL"
  type        = string
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Initial storage allocated to the database in GiB"
  type        = number
  default     = 20
}

variable "deletion_protection" {
  description = "Protect the RDS instance from accidental deletion"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final database snapshot during deletion"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags applied to database resources"
  type        = map(string)
  default     = {}
}