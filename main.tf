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
resource "tencentcloud_lighthouse_instance" "aws_instance" {
  zone = "${var.region}-1"
  # 其他配置...
}

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

