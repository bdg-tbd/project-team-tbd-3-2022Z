variable "project_name" {
  type        = string
  description = "Project name"
}

variable "region" {
  type        = string
  description = "GCP region"
}

variable "test" {
  type        = string
  description = "test"
  default     = "value"
}
