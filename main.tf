# ==========================
# Terraform 与 Provider 配置
# ==========================
terraform {
  required_providers {
    tencentcloud = {
      source  = "tencentcloudstack/tencentcloud"
      version = ">= 1.81.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "tencentcloud" {
  secret_id  = var.TENCENT_SECRET_ID
  secret_key = var.TENCENT_SECRET_KEY
  region     = var.region
}

provider "aws" {
  region = var.region
}

# ==========================
# 变量声明
# ==========================
variable "region" {
  description = "云服务区域"
  default     = "ap-beijing"
}

variable "key_name" {
  description = "SSH 密钥名称（仅 AWS 使用）"
  default     = "mykey"
}

variable "lighthouse_key_id" {
  description = "腾讯云 Lighthouse 密钥 ID（形如 skey-xxxxxxxx）"
  type        = string
}

variable "image_id" {
  description = "镜像 ID"
  default     = "lighthouse-ubuntu-22.04"   # 腾讯云 Lighthouse 镜像
}

variable "plan_id" {
  description = "实例规格 ID"
  default     = "bundle_2024_gen_2c4g20g"
}

variable "docker_image" {
  description = "Docker 镜像"
  default     = "nginx:1.25-alpine"
}

variable "TENCENT_SECRET_ID" {
  description = "Tencent Cloud Secret ID"
  type        = string
  sensitive   = true
}

variable "TENCENT_SECRET_KEY" {
  description = "Tencent Cloud Secret Key"
  type        = string
  sensitive   = true
}

# ==========================
# 本地变量
# ==========================
locals {
  cloud_provider = "tencent"   # 可改为 "aws" 来切换部署
}

# ==========================
# 腾讯云 Lighthouse 实例
# ==========================
resource "tencentcloud_lighthouse_instance" "lcs" {
  count         = local.cloud_provider == "tencent" ? 1 : 0
  bundle_id     = var.plan_id
  blueprint_id  = var.image_id
  instance_name = "lcs-blackbox"
  zone          = "${var.region}-3"
  login_key_id = var.lighthouse_key_id

  renew_flag    = 0
}

# 腾讯云 Lighthouse 防火墙规则
resource "tencentcloud_lighthouse_firewall_rule" "lcs_firewall" {
  count       = local.cloud_provider == "tencent" ? 1 : 0
  instance_id = tencentcloud_lighthouse_instance.lcs[0].id

  firewall_rules {
    protocol   = "TCP"
    port       = "22"
    cidr_block = "0.0.0.0/0"
    action     = "ACCEPT"
  }

  firewall_rules {
    protocol   = "TCP"
    port       = "80"
    cidr_block = "0.0.0.0/0"
    action     = "ACCEPT"
  }
}

# ==========================
# AWS EC2 实例（可选）
# ==========================
resource "aws_instance" "lcs" {
  count         = local.cloud_provider == "aws" ? 1 : 0
  ami           = var.image_id   # 如使用 AWS，请换成 ami-xxxxxxxx
  instance_type = "t4g.small"
  key_name      = var.key_name

  tags = {
    Name = "lcs-blackbox"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io
    systemctl enable --now docker
    docker run -d --name lcs -p 80:80 ${var.docker_image}
  EOF
  )
}

# ==========================
# 输出
# ==========================
output "public_ip" {
  value = local.cloud_provider == "tencent" ? (
    length(tencentcloud_lighthouse_instance.lcs) > 0 ? tencentcloud_lighthouse_instance.lcs[0].public_ip : null
  ) : (
    length(aws_instance.lcs) > 0 ? aws_instance.lcs[0].public_ip : null
  )
}

output "ssh_cmd" {
  value = local.cloud_provider == "tencent" ? (
    length(tencentcloud_lighthouse_instance.lcs) > 0 ? "ssh root@${tencentcloud_lighthouse_instance.lcs[0].public_ip}" : ""
  ) : (
    length(aws_instance.lcs) > 0 ? "ssh ec2-user@${aws_instance.lcs[0].public_ip}" : ""
  )
}
