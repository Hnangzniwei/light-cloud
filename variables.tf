variable "bundle_id_tencent" {
  description = "腾讯云 Lighthouse 套餐 ID"
  type        = string
  default     = "bundle_2024_gen_basic_1c1g"
}

variable "image_id_tencent" {
  description = "腾讯云 Lighthouse 镜像 ID"
  type        = string
  default     = "lh-ubuntu22.04"
}

variable "ami_aws" {
  description = "AWS EC2 AMI ID"
  type        = string
  default     = "ami-0c104734a5656a180"  # Amazon Linux 2023
}

variable "instance_type_aws" {
  description = "AWS EC2 实例类型"
  type        = string
  default     = "t3.micro"
}

variable "subnet_id_aws" {
  description = "AWS 子网 ID"
  type        = string
  default     = "subnet-12345678"  # 替换为你的子网
}

variable "instance_name" {
  description = "实例名称"
  type        = string
  default     = "multi-cloud-web"
}
