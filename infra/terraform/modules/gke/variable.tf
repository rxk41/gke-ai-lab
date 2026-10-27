variable "project_id" {
  type = string
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

variable "cluster_name" {
  type    = string
  default = "gitops-dev-gke"
}

variable "network" {
  type    = string
  default = "gitops-dev-vpc"
}

variable "subnetwork" {
  type    = string
  default = "gitops-dev-subnet"
}

variable "node_service_account" {
  type = string
}

variable "node_count" {
  type    = number
  default = 3
}

variable "machine_type" {
  type    = string
  default = "e2-standard-4"
}

variable "disk_size_gb" {
  type    = number
  default = 25
}