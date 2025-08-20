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

variable "region" {
  description = "云服务区域"
  default     = "ap-beijing"
}

variable "key_name" {
  description = "SSH 密钥名称"
  default     = "mykey"
}

variable "image_id" {
  description = "镜像 ID"
  default     = "lighthouse-ubuntu-22.04"
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

locals {
  cloud_provider = "tencent"
}

# 腾讯云轻量应用服务器
resource "tencentcloud_lighthouse_instance" "lcs" {
  count         = local.cloud_provider == "tencent" ? 1 : 0
  bundle_id     = var.plan_id
  blueprint_id  = var.image_id
  instance_name = "lcs-blackbox"
  zone          = "${var.region}-3"
  key_name      = var.key_name
  renew_flag    = 0
}

# 防火墙规则（单独资源）
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

# AWS EC2 实例
resource "aws_instance" "lcs" {
  count         = local.cloud_provider == "aws" ? 1 : 0
  ami           = var.image_id
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

# 输出公网 IP
output "public_ip" {
  value = local.cloud_provider == "tencent" ? (
    length(tencentcloud_lighthouse_instance.lcs) > 0 ? tencentcloud_lighthouse_instance.lcs[0].public_ip : null
  ) : (
    length(aws_instance.lcs) > 0 ? aws_instance.lcs[0].public_ip : null
  )
}

# 输出 SSH 命令
output "ssh_cmd" {
  value = local.cloud_provider == "tencent" ? (
    length(tencentcloud_lighthouse_instance.lcs) > 0 ? "ssh root@${tencentcloud_lighthouse_instance.lcs[0].public_ip}" : ""
  ) : (
    length(aws_instance.lcs) > 0 ? "ssh ec2-user@${aws_instance.lcs[0].public_ip}" : ""
  )
}
