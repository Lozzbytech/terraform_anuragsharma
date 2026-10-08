variable "aws_region" {
  description = "The AWS region to deploy the instance into"
  type        = string
}

variable "aws_access_key" {
  description = "AWS IAM user access key identifier"
  type        = string
  sensitive   = true 
}

variable "aws_secret_key" {
  description = "AWS IAM user secret access key"
  type        = string
  sensitive   = true 
}
