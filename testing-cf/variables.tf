variable "aws_region" {
  description = "Region where my env is deployed"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  type        = string
  description = "The name of the bucket without the www. prefix. Normally domain_name."
}

variable "domain_name" {
  type        = string
  description = "The name of the bucket without the www. prefix. Normally domain_name."
}