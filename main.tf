variable "region" {
  description = "云服务区域"
  default     = "ap-beijing"
}

variable "key_name" {
  description = "SSH密钥名称"
  default     = "mykey"
}

variable "image_id" {
  description = "镜像ID"
  default     = "lighthouse-ubuntu-22.04"  # 腾讯云默认值
}

variable "plan_id" {
  description = "实例规格ID"
  default     = "bundle_2024_gen_2c4g20g"  # 腾讯云默认值
}

variable "docker_image" {
  description = "Docker镜像"
  default     = "nginx:1.25-alpine"
}

# 腾讯云配置
provider "tencentcloud" {
  region = var.region
}

# AWS配置
provider "aws" {
  region = var.region
}

# 根据CLOUD_PROVIDER变量选择部署哪个云服务
locals {
  cloud_provider = coalesce(lookup(jsondecode(chomp(file("/dev/stdin"))), "CLOUD_PROVIDER", null), "tencent")
}

# 腾讯云轻量应用服务器
resource "tencentcloud_lighthouse_instance" "lcs" {
  count         = local.cloud_provider == "tencent" ? 1 : 0
  bundle_id     = var.plan_id
  blueprint_id  = var.image_id
  instance_name = "lcs-blackbox"
  zone          = "${var.region}-3"
  key_ids       = [var.key_name]
  
  firewall_rules {
    protocol    = "TCP"
    port        = "22"
    cidr_block  = "0.0.0.0/0"
  }
  
  firewall_rules {
    protocol    = "TCP"
    port        = "80"
    cidr_block  = "0.0.0.0/0"
  }
}

# AWS EC2实例
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
  
  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io
    systemctl enable --now docker
    docker run -d --name lcs --restart=always -p 80:80 ${var.docker_image}
  EOF
}

# 输出公网IP
output "public_ip" {
  value = local.cloud_provider == "tencent" ? (
    length(tencentcloud_lighthouse_instance.lcs) > 0 ? tencentcloud_lighthouse_instance.lcs[0].public_ip : ""
  ) : (
    length(aws_instance.lcs) > 0 ? aws_instance.lcs[0].public_ip : ""
  )
}

# 输出SSH命令
output "ssh_cmd" {
  value = local.cloud_provider == "tencent" ? (
    length(tencentcloud_lighthouse_instance.lcs) > 0 ? "ssh root@${tencentcloud_lighthouse_instance.lcs[0].public_ip}" : ""
  ) : (
    length(aws_instance.lcs) > 0 ? "ssh ec2-user@${aws_instance.lcs[0].public_ip}" : ""
  )
}
