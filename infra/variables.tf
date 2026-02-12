variable "aws_region" { type = string }
variable "project_name" { type = string }

variable "container_port" {
  type    = number
  default = 3000
}

# VPC CIDRs
variable "vpc_cidr" { type = string }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }

# GitHub Actions will push image with this tag (default latest)
variable "image_tag" {
  type    = string
  default = "latest"
}
