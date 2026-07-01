variable "environment" {
  type    = string
  default = "dev"
}

variable "project" {
  type    = string
  default = "aws-3-tier"
}

variable "recover_window" {
  type    = number
  default = 7
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "engine" {
  type    = string
  default = "postgres"
}

variable "db_host" {
  type      = string
  sensitive = true
}

variable "db_port" {
  type      = number
  sensitive = true
}

variable "db_name" {
  type      = string
  sensitive = true
}
