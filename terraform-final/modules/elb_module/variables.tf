variable "vpc_id" {
  type = string
}

variable "DEST_CIDR" {
  type = string
  default = "0.0.0.0/0"
}
variable "HTTP" {
  type = number
  default = "80"
}
variable "SSH" {
  type = number
  default = "22"
}

variable "proxy-server-id" {
  type = list
}

variable "apache-server-id" {
  type = list
}


variable "proxy-lb-subnets" {
  type = list
}

variable "apache-lb-subnets" {
  type = list
}