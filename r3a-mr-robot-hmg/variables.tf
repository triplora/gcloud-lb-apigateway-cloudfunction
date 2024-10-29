variable "project_id" {
  type        = string
  default     = "r3a-mr-robot-hmg"
  description = "Project ID"
}

variable "default_region" {
  type        = string
  default     = "us-central1"
  description = "Default Region"
}

variable "env" {
  type        = string
  default     = "hmg"
  description = "Environment"
}