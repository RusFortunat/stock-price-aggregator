variable "project_name" {
  description = "Short name used to prefix/tag all resources"
  type        = string
  default     = "stock-price-aggregator"
}

variable "environment" {
  description = "Deployment environment (dev/simu/prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "azs" {
  description = "Availability zones to spread subnets across (MWAA needs >= 2)"
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.20.101.0/24", "10.20.102.0/24"]
}

variable "mwaa_environment_class" {
  description = "MWAA environment size"
  type        = string
  default     = "mw1.small"
}

variable "mwaa_airflow_version" {
  type    = string
  default = "2.10.1"
}

variable "dbt_image_tag" {
  description = "Tag for the dbt Docker image pushed to ECR"
  type        = string
  default     = "latest"
}

variable "api_image_tag" {
  description = "Tag for the API Docker image pushed to ECR"
  type        = string
  default     = "latest"
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

variable "alpha_vantage_api_key" {
  type      = string
  sensitive = true
}