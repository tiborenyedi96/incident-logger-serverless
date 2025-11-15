variable "cidr_block" {
  type    = string
  default = "10.0.0.0/20"
}

variable "name" {
  type    = string
  default = "incident-logger"
}

variable "private_a"{
  type = string
  default = "10.0.0.0/24"
}

variable "private_b"{
  type = string
  default = "10.0.1.0/24"
}