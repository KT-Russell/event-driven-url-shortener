variable "name_prefix" {
  description = "Prefix used when naming messaging resources"
  type        = string
}

variable "visibility_timeout_seconds" {
  description = "How long a received message stays hidden while the worker processes it"
  type        = number
  default     = 60
}

variable "message_retention_seconds" {
  description = "How long unprocessed click events remain in the main queue (4days)"
  type        = number
  default     = 345600
}

variable "receive_wait_time_seconds" {
  description = "Long-polling wait time for ReceiveMessage requests"
  type        = number
  default     = 20
}

variable "dlq_message_retention_seconds" {
  description = "How long failed messages remain available in the dead-letter queue (14 days)"
  type        = number
  default     = 1209600
}

variable "max_receive_count" {
  description = "Number of failed receives before a message is moved to the DLQ"
  type        = number
  default     = 5
}

variable "tags" {
  description = "Common tags applied to SQS resources"
  type        = map(string)
  default     = {}
}