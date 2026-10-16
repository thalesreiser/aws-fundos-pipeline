variable "region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Prefixo dos recursos"
  type        = string
  default     = "aws-fundos-pipeline"
}

variable "alert_email" {
  description = "E-mail para alertas de falha (SNS) e de orçamento"
  type        = string
}
