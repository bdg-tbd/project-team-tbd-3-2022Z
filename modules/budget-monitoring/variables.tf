variable "billing_account" {
  type        = string
  description = "Billing account which should be monitored"
}

variable "project_name" {
  type        = string
  description = "Name of the GCP project"
}

variable "monthly_budget" {
  type        = string
  description = "Monthly budget"
  default     = "50"
}

variable "notification_thresholds" {
  type        = list(string)
  description = "Thresholds for notifications"
  default     = ["0.5", "0.8", "1"]
}
