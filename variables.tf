# 云厂商选择：支持 "tencent" 或 "aws"
variable "cloud_provider" {
  description = "选择云厂商: tencent 或 aws"
  type        = string
  default     = "tencent"
  validation {
    condition = contains(["tencent", "aws"], lower(var.cloud_provider))
    error_message = "cloud_provider 必须是 'tencent' 或 'aws'。"
  }
}

# 区域设置
variable "region" {
  description = "云服务区域，如 ap-beijing, us-east-1"
  type        = string
  default     = "ap-beijing"
}

# 腾讯云密钥（敏感）
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

# AWS 相关变量
variable "AWS_ASSUME_ROLE_ARN" {
  description = "AWS Assume Role ARN（可选）"
  type        = string
  default     = ""
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
  default     = "subnet-xxxxxxxx"
}

variable "AWS_SECURITY_GROUP_IDS" {
  description = "AWS 安全组 ID 列表"
  type        = list(string)
  default     = ["sg-xxxxxxxx"]
}

variable "aws_key_name" {
  description = "AWS EC2 密钥对名称"
  type        = string
  default     = "mykey"
}

# 实例通用配置
variable "instance_name" {
  description = "实例名称"
  type        = string
  default     = "demo-instance"
}

# 腾讯云 Lighthouse 配置
variable "tencent_blueprint_id" {
  description = "腾讯云镜像 ID（Blueprint）"
  type        = string
  default     = "lhbp-8v7ii88e" # Ubuntu 20.04
}

variable "tencent_bundle_id" {
  description = "腾讯云套餐 ID（Bundle）"
  type        = string
  default     = "bundle20m" # 1C1G
}

variable "tencent_renew_flag" {
  description = "自动续费标志: NOTIFY_AND_AUTO_RENEW / DISABLE_NOTIFY_AND_MANUAL_RENEW"
  type        = string
  default     = "NOTIFY_AND_AUTO_RENEW"
}

# 实例登录密码（敏感，需符合复杂度）
variable "instance_password" {
  description = "Lighthouse 实例登录密码，8-30位，需包含大小写字母、数字、特殊字符"
  type        = string
  sensitive   = true

  validation {
    condition = (
      length(var.instance_password) >= 8 &&
      length(var.instance_password) <= 30 &&
      length(regexall("[A-Z]", var.instance_password)) > 0 &&
      length(regexall("[a-z]", var.instance_password)) > 0 &&
      length(regexall("[0-9]", var.instance_password)) > 0 &&
      length(regexall("[!@#<LaTex>$%^&*()\_+[ty-4bs]-=[ty-4bs][[ty-4bs]]{}|;':",./<>?]", var.instance\_password)) > 0[ty-n]    )[ty-n]    error\_message = "密码必须为8-30位，且包含大小写字母、数字和特殊字符。"[ty-n]  }[ty-n]}[ty-n][ty-n]# 腾讯云各区域默认可用区映射（避免 $</LaTex>{region}-1 不可用）
variable "tencent_zones" {
  description = "腾讯云各 region 对应的可用区映射"
  type        = map(string)
  default = {
    "ap-beijing"      = "ap-beijing-1"
    "ap-shanghai"     = "ap-shanghai-2"
    "ap-guangzhou"    = "ap-guangzhou-1"
    "ap-chengdu"      = "ap-chengdu-1"
    "na-siliconvalley" = "na-siliconvalley-1"
    "eu-frankfurt"    = "eu-frankfurt-1"
  }
}
