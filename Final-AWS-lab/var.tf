variable "VPC_CIDR" {
  type = string
}

variable "PRIVATE_SUBNET1_CIDR" {
  type = string
}
variable "PRIVATE_SUBNET2_CIDR" {
  type = string
}
variable "PRIVATE_SUBNET3_CIDR" {
  type = string
}

variable "PUBLIC_SUBNET1_CIDR" {
  type = string
}

variable "PUBLIC_SUBNET2_CIDR" {
  type = string
}

variable "DEST_CIDR" {
  type = string
}

variable "SSH" {
  type = number
}
variable "HTTP" {
  type = number
}
variable "HTTPS" {
  type = number
}

variable "SRV_IMG" {
  type = string
}