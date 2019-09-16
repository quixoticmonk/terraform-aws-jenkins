variable "access_key" {}

variable "secret_key" {}

variable "region" {
  description = "AWS region for hosting our your network"
  default = "us-east-2"
}

variable "private_key_path" {}

variable "key_name" {}

variable "dest_cidr_block" {
  default = "0.0.0.0/0"
}