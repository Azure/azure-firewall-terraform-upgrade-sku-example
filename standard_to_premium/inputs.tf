variable "resource_group_name" {
  default = "azfw-scu-rg"
  type    = string
}

variable "location" {
  default = "East US 2"
  type    = string
}

variable "firewall_policy_name" {
  default = "azfw-scu-policy"
  type    = string
}

variable "firewall_name" {
  default = "azfw-to-upgrade"
  type    = string
}

variable "upgrade_firewall" {
  default = false
  type    = bool
}