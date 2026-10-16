variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Resource name prefix"
  type        = string
  default     = "aws-fundos-pipeline"
}

variable "alert_email" {
  description = "E-mail for failure (SNS) and budget alerts"
  type        = string
}
