variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

variable "github_repository" {
  type        = string
  description = "Exact OWNER/REPOSITORY for GitHub OIDC Workload Identity Federation."
}

variable "sonar_secret_id" {
  type    = string
  default = "sonarcloud-token"
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
  default = 20
}

variable "workload_identity_provider_id" {
  type    = string
  default = "github-provider-v2"
}

variable "workload_identity_pool_id" {
  type    = string
  default = "github-actions-pool-v2"
}
variable "network" {
  type    = string
  default = "gitops-dev-vpc"
}

variable "subnetwork" {
  type    = string
  default = "gitops-dev-subnet"
}