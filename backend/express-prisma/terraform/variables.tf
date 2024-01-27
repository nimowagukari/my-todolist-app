variable "hosted_zone_name" {
  type = string
}

variable "alb_name" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
  description = "ECS サービスに紐付けるサブネット ID のリスト"
}

variable "security_group_ids" {
  type = list(string)
  description = "ECS サービスに紐付けるセキュリティグループ ID のリスト"
}

variable "assign_public_ip" {
  type = bool
  description = "ECS サービスにパブリック IP を付与するか否か"
}
