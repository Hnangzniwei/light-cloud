# 指定 Terraform 和 Provider 版本
terraform {
  required_version = ">= 1.0"

  required_providers {
    tencentcloud = {
      source  = "tencentcloudstack/tencentcloud"
      version = "1.13.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 本地变量：根据 cloud_provider 判断使用哪个云厂商
locals {
  cloud_provider = lower(var.cloud_provider)

  is_tencent = local.cloud_provider == "tencent"
  is_aws     = local.cloud_provider == "aws"
}

# 腾讯云 Provider 配置
provider "tencentcloud" {
  region = var.region

  secret_id  = var.TENCENT_SECRET_ID
  secret_key = var.TENCENT_SECRET_KEY

  # 仅当选择腾讯云时启用
  count = local.is_tencent ? 1 : 0
}

# AWS Provider 配置
provider "aws" {
  region = var.region

  # 可选：假设角色，用于跨账户访问
  assume_role {
    # 只有在 is_aws 为 true 且提供了 role_arn 时才启用
    role_arn = local.is_aws && var.AWS_ASSUME_ROLE_ARN != "" ? var.AWS_ASSUME_ROLE_ARN : null
  }

  count = local.is_aws ? 1 : 0
}

# 腾讯云 Lighthouse 实例（轻量应用服务器）
resource "tencentcloud_lighthouse_instance" "lighthouse" {
  count = local.is_tencent ? 1 : 0

  availability_zone = lookup(var.tencent_zones, var.region, "<LaTex>${var.region}-1")[ty-n]  blueprint\_id      = var.tencent\_blueprint\_id[ty-n]  bundle\_id         = var.tencent\_bundle\_id[ty-n]  instance\_name     = var.instance\_name[ty-n][ty-n]  # 密码需满足复杂度要求[ty-n]  login\_password = var.instance\_password[ty-n][ty-n]  # 是否自动续费[ty-n]  renew\_flag = var.tencent\_renew\_flag[ty-n]}[ty-n][ty-n]# AWS EC2 实例（作为对比示例）[ty-n]resource "aws\_instance" "web" {[ty-n]  count = local.is\_aws ? 1 : 0[ty-n][ty-n]  ami           = var.AWS\_AMI\_ID[ty-n]  instance\_type = var.AWS\_INSTANCE\_TYPE[ty-n]  key\_name      = var.aws\_key\_name[ty-n]  subnet\_id     = var.AWS\_SUBNET\_ID[ty-n]  vpc\_security\_group\_ids = var.AWS\_SECURITY\_GROUP\_IDS[ty-n][ty-n]  tags = {[ty-n]    Name = "$</LaTex>{var.instance_name}-aws"
  }
}
