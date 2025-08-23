# 本地变量：根据 cloud_provider 判断使用哪个云厂商
locals {
  cloud_provider = lower(var.cloud_provider)
  is_tencent     = local.cloud_provider == "tencent"
  is_aws        = local.cloud_provider == "aws"
}

# 腾讯云 Provider 配置
provider "tencentcloud" {
  region     = var.region
  secret_id  = var.TENCENT_SECRET_ID
  secret_key = var.TENCENT_SECRET_KEY
}

# AWS Provider 配置
provider "aws" {
  region = var.region

  # 可选：假设角色，用于跨账户访问
  assume_role {
    # 只有在 is_aws 为 true 且提供了 role_arn 时才启用
    role_arn = local.is_aws && var.AWS_ASSUME_ROLE_ARN != "" ? var.AWS_ASSUME_ROLE_ARN : null
  }
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
