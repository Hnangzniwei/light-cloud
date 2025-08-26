variable "cloud_provider" {
  description = "选择云厂商: tencent 或 aws"
  type        = string
  default     = "tencent"
  validation {
    condition     = contains(["tencent", "aws"], lower(var.cloud_provider))
    error_message = "cloud_provider 必须是 'tencent' 或 'aws'。"
  }
}

variable "region" {
  description = "AWS 区域，例如 us-east-1, ap-northeast-1 等"
  type        = string
  default     = "us-east-1"
}

variable "aws_access_key" {
  description = "AWS 访问密钥 ID"
  type        = string
  sensitive   = true  # 防止在输出中打印
}

variable "aws_secret_key" {
  description = "AWS 私密访问密钥"
  type        = string
  sensitive   = true
}

variable "AWS_AMI_ID" {
  description = "AWS AMI 镜像 ID"
  type        = string
  default     = "ami-0c0e870dab17d572a" # Amazon Linux 2 in us-east-1
}

variable "AWS_INSTANCE_TYPE" {
  description = "AWS 实例类型"
  type        = string
  default     = "t3.micro"
}

variable "AWS_SUBNET_ID" {
  description = "AWS 子网 ID"
  type        = string
  default     = ""
}

variable "AWS_SECURITY_GROUP_IDS" {
  description = "AWS 安全组 ID 列表"
  type        = list(string)
  default     = []
}

variable "aws_key_name" {
  description = "AWS EC2 密钥对名称"
  type        = string
  default     = "mykey"
}

variable "tencent_blueprint_id" {
  description = "腾讯云镜像 ID (Blueprint)"
  type        = string
  default     = "lhbp-8v7ii88e" # Ubuntu 20.04
}

variable "tencent_bundle_id" {
  description = "腾讯云套餐 ID (Bundle)"
  type        = string
  default     = "bundle20m" # 1C1G
}

variable "tencent_renew_flag" {
  description = "自动续费标志: NOTIFY_AND_AUTO_RENEW / DISABLE_NOTIFY_AND_MANUAL_RENEW"
  type        = string
  default     = "NOTIFY_AND_AUTO_RENEW"
}

variable "instance_password" {
  description = "Lighthouse 实例登录密码，8-30位，需包含大小写字母、数字、特殊字符"
  type        = string
  sensitive   = true
  validation {
    condition = alltrue([
      length(var.instance_password) >= 8,
      length(var.instance_password) <= 30,
      can(regex("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^\\da-zA-Z]).*$", var.instance_password))
    ])
    error_message = "密码必须为8-30位，且包含大小写字母、数字和特殊字符。"
  }
}

variable "tencent_zones" {
  description = "腾讯云各 region 对应的可用区映射"
  type        = map(string)
  default     = {
    "ap-beijing"     = "ap-beijing-1"
    "ap-shanghai"    = "ap-shanghai-2"
    "ap-guangzhou"   = "ap-guangzhou-1"
    "ap-chengdu"     = "ap-chengdu-1"
    "na-siliconvalley" = "na-siliconvalley-1"
    "eu-frankfurt"    = "eu-frankfurt-1"
  }
}
