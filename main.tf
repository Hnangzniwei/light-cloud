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
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # 推荐使用最新稳定版
    }
  }
}

# 配置 AWS Provider
provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}



# 腾讯云 Lighthouse 实例（轻量应用服务器）
resource "tencentcloud_lighthouse_instance" "lighthouse" {
  count = local.is_tencent ? 1 : 0
  availability_zone = lookup(var.tencent_zones, var.region, "${var.region}-1")
  # 其他 Lighthouse 实例配置项...
}

# AWS 实例（示例，根据实际需求配置）
resource "aws_instance" "example" {
  count         = local.is_aws ? 1 : 0
  ami           = var.aws_ami
  instance_type = var.aws_instance_type
  # 其他 AWS 实例配置项...
}
