locals {
  services = toset([
    "compute.googleapis.com", "container.googleapis.com", "iam.googleapis.com",
    "iamcredentials.googleapis.com", "cloudresourcemanager.googleapis.com",
    "artifactregistry.googleapis.com", "sqladmin.googleapis.com",
    "servicenetworking.googleapis.com", "secretmanager.googleapis.com",
    "sts.googleapis.com", "monitoring.googleapis.com", "logging.googleapis.com"
  ])
}
resource "google_project_service" "enabled" {
  for_each           = local.services
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}
