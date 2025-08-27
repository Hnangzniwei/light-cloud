# 本地变量：根据 cloud_provider 判断使用哪个云厂商
locals {
  cloud_provider = lower(var.cloud_provider)
  is_tencent     = local.cloud_provider == "tencent"
  is_aws        = local.cloud_provider == "aws"
}

# main.tf 或 providers.tf

# 指定 Terraform 所需的 provider 和版本
terraform {
  required_providers {
    tencentcloud = {
      source  = "tencentcloudstack/tencentcloud"
      version = "1.82.18"   # 可选：锁定版本，不写则拉最新
    }
  }
}

provider "tencentcloud" {
  secret_id  = var.tencent_secret_id
  secret_key = var.tencent_secret_key
}

variable "tencent_secret_id" {
  description = "The secret ID for Tencent Cloud"
}

variable "tencent_secret_key" {
  description = "The secret key for Tencent Cloud"
}

variable "aws_ami" {
  description = "The AMI ID for the AWS instance"
  default     = "ami-xxxxxxxx"
}

variable "aws_instance_type" {
  description = "The instance type for the AWS instance"
  default     = "t2.micro"
}

resource "aws_instance" "example" {
  ami           = var.aws_ami
  instance_type = var.aws_instance_type
}
