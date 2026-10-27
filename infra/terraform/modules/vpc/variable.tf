variable "project_id" { type = string }
variable "region" { type = string }
variable "network_name" {
  type    = string
  default = "gitops-dev-vpc"
}
variable "subnetwork_name" {
  type    = string
  default = "gitops-dev-subnet"
}
