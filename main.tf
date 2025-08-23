terraform {
  required_providers {
    tencentcloud = {
      source  = "tencentcloudstack/tencentcloud"
      version = "~> 1.84" # 尝试使用其他版本
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


# 全局变量
locals {
  cloud_provider = var.cloud_provider
  is_tencent     = local.cloud_provider == "tencent"
  is_aws         = local.cloud_provider == "aws"
}

# Provider 配置
provider "tencentcloud" {
  region       = var.region
  secret_id    = var.TENCENT_SECRET_ID
  secret_key   = var.TENCENT_SECRET_KEY
  skip_create_service = !local.is_tencent
}

provider "aws" {
  region  = var.region
  assume_role = local.is_aws ? null : {
    role_arn      = "arn:aws:iam::000000000000:role/NonExistentRole"
    session_name  = "SkipProvider"
  }
}

# 变量定义
variable "cloud_provider" {
  description = "选择云厂商: 'tencent' 或 'aws'"
  type        = string
  default     = "tencent"
}

variable "region" {
  description = "云区域, 如 ap-beijing / us-east-1"
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
  description = "Lighthouse 实例登录密码（8-30位, 含大小写、数字、特殊字符）"
  type        = string
  sensitive   = true
}

variable "aws_key_name" {
  description = "AWS EC2 密钥对名称"
  type        = string
  default     = "mykey"
}

# Tencent Cloud Lighthouse 实例
resource "tencentcloud_lighthouse_instance" "lighthouse_instance" {
  count = local.is_tencent ? 1 : 0

  zone = "<LaTex>${var.region}-1"[ty-n]  # 其他配置...[ty-n]}[ty-n][ty-n]# AWS EC2 实例[ty-n]resource "aws\_instance" "ec2\_instance" {[ty-n]  count = local.is\_aws ? 1 : 0[ty-n][ty-n]  ami           = "ami-0c55b159cbfafe1f0"[ty-n]  instance\_type = "t2.micro"[ty-n]  key\_name      = var.aws\_key\_name[ty-n][ty-n]  # 其他配置...[ty-n]}[ty-n][ty-n]# 安全组规则[ty-n]resource "aws\_security\_group" "sg" {[ty-n]  count = local.is\_aws ? 1 : 0[ty-n][ty-n]  name        = "allow\_ssh\_and\_http"[ty-n]  description = "Allow SSH and HTTP"[ty-n][ty-n]  ingress {[ty-n]    from\_port   = 22[ty-n]    to\_port     = 22[ty-n]    protocol    = "tcp"[ty-n]    cidr\_blocks = ["0.0.0.0/0"][ty-n]  }[ty-n][ty-n]  ingress {[ty-n]    from\_port   = 80[ty-n]    to\_port     = 80[ty-n]    protocol    = "tcp"[ty-n]    cidr\_blocks = ["0.0.0.0/0"][ty-n]  }[ty-n][ty-n]  egress {[ty-n]    from\_port   = 0[ty-n]    to\_port     = 0[ty-n]    protocol    = "-1"[ty-n]    cidr\_blocks = ["0.0.0.0/0"][ty-n]  }[ty-n]}[ty-n][ty-n]# 输出[ty-n]output "public\_ip" {[ty-n]  value = concat(tencentcloud\_lighthouse\_instance.lighthouse\_instance.*.public\_ip, aws\_instance.ec2\_instance.*.public\_ip)[0][ty-n]}[ty-n][ty-n]output "ssh\_command" {[ty-n]  value = "ssh root@$</LaTex>{element(concat(tencentcloud_lighthouse_instance.lighthouse_instance.*.public_ip, aws_instance.ec2_instance.*.public_ip), 0)}"
}
