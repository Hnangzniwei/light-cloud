# 指定 Terraform 版本和所需 Provider
terraform {
  required_providers {
    tencentcloud = {
      source  = "tencentcloudstack/tencentcloud"
      version = "~> 1.85"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ================ 全局变量 ================
locals {
  cloud_provider = var.cloud_provider  # "tencent" 或 "aws"
  is_tencent     = local.cloud_provider == "tencent"
  is_aws         = local.cloud_provider == "aws"
}

# ================ Provider 配置 ================
provider "tencentcloud" {
  region     = var.region
  secret_id  = var.TENCENT_SECRET_ID
  secret_key = var.TENCENT_SECRET_KEY
  # 仅当使用腾讯云时才启用
  skip_create_service = !local.is_tencent
}

provider "aws" {
  region = var.region
  # 仅当使用 AWS 时才启用
  assume_role = local.is_aws ? null : {
    role_arn           = "arn:aws:iam::000000000000:role/NonExistentRole"
    session_name       = "SkipProvider"
  }
}

# ================ 变量定义 ================
variable "cloud_provider" {
  description = "选择云厂商: 'tencent' 或 'aws'"
  type        = string
  default     = "tencent"
}

variable "region" {
  description = "云区域，如 ap-beijing / us-east-1"
  type        = string
  default     = "ap-beijing"
}

variable "TENCENT_SECRET_ID" {
  description = "腾讯云 SecretId"
  type        = string
  sensitive   = true
}

variable "TENCENT_SECRET_KEY" {
  description = "腾讯云 SecretKey"
  type        = string
  sensitive   = true
}

variable "instance_password" {
  description = "Lighthouse 实例登录密码（8-30位，含大小写、数字、特殊字符）"
  type        = string
  sensitive   = true
}

variable "aws_key_name" {
  description = "AWS EC2 密钥对名称"
  type        = string
  default     = "mykey"
}

# ================ 腾讯云 Lighthouse 实例 ================
resource "tencentcloud_lighthouse_instance" "web" {
  count = local.is_tencent ? 1 : 0

  bundle_id       = var.bundle_id_tencent
  blueprint_id    = var.image_id_tencent
  instance_name   = var.instance_name
  zone            = "<LaTex>${var.region}-1"[ty-n]  login\_settings {[ty-n]    password = var.instance\_password[ty-n]  }[ty-n][ty-n]  user\_data = <<EOF[ty-n]#!/bin/bash[ty-n]set -e[ty-n]apt-get update[ty-n]apt-get install -y docker.io[ty-n]systemctl start docker[ty-n]docker run -d -p 80:80 --restart=always nginx:alpine[ty-n]EOF[ty-n]}[ty-n][ty-n]# ================ AWS EC2 实例 ================[ty-n]resource "aws\_instance" "web" {[ty-n]  count = local.is\_aws ? 1 : 0[ty-n][ty-n]  ami           = var.ami\_aws[ty-n]  instance\_type = var.instance\_type\_aws[ty-n]  key\_name      = var.aws\_key\_name[ty-n]  vpc\_security\_group\_ids = [aws\_security\_group.allow\_http\_ssh.id][ty-n]  subnet\_id     = var.subnet\_id\_aws[ty-n]  user\_data = <<EOF[ty-n]#!/bin/bash[ty-n]set -e[ty-n]yum update -y[ty-n]amazon-linux-extras install docker -y[ty-n]systemctl start docker[ty-n]docker run -d -p 80:80 --restart=always nginx:alpine[ty-n]EOF[ty-n]  tags = {[ty-n]    Name = var.instance\_name[ty-n]  }[ty-n]}[ty-n][ty-n]# ================ AWS 安全组 ================[ty-n]resource "aws\_security\_group" "allow\_http\_ssh" {[ty-n]  count = local.is\_aws ? 1 : 0[ty-n][ty-n]  name        = "$</LaTex>{var.instance_name}-sg"
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ================ 输出 ================
output "public_ip" {
  value = aws_instance.web[0].public_ip
}


output "ssh_command" {
  value = "ssh root@${tencentcloud_lighthouse_instance.web[0].public_ip}"
}

