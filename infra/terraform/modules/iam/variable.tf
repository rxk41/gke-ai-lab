variable "project_id" { type = string }
variable "github_repository" {
  type        = string
  description = "Exact OWNER/REPOSITORY allowed to federate from GitHub Actions."
  default     = "rxk41/gke-GitOps-final-"
}
variable "region" { type = string }
variable "artifact_repository_id" {
  type    = string
  default = "gitops-apps"
}
variable "sonar_secret_id" {
  type    = string
  default = "sonarcloud-token"
}
# variable "workload_identity_pool_id" {
#   type    = string
#   default = "github-actions-pool"
# }
# variable "workload_identity_provider_id" {
#   type    = string
#   default = "github-provider"
# }

variable "workload_identity_pool_id" {
  type    = string
  default = "github-actions-pool-v2"
}

variable "github_actions_service_account_id" {
  type    = string
  default = "github-actions-ci"
}
variable "gke_workload_service_account_id" {
  type    = string
  default = "store-app-workload"
}

variable "workload_identity_provider_id" {
  type    = string
  default = "github-provider-v2"
}