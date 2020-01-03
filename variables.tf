variable "namespace" {
  type = string
  default = "sa"
}

variable "stage" {
  type = string
  default = "dev"
}

variable "name" {
  type = string
  default = "vpc"
}

variable "cidr_block" {
  type = string
  default = "10.0.0.0/16"
}