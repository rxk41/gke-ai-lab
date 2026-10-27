data "google_project" "current" {
  project_id = var.project_id
}
resource "google_iam_workload_identity_pool" "github" {
  project = var.project_id
  workload_identity_pool_id = var.workload_identity_pool_id
  display_name = "GitHub Actions"
  description = "OIDC federation for the selected GitHub repository"
}
resource "google_iam_workload_identity_pool_provider" "github" {
  project = var.project_id
  workload_identity_pool_id = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = var.workload_identity_provider_id
  display_name = "GitHub OIDC provider"
  attribute_mapping = {
    "google.subject" = "assertion.sub"
    "attribute.actor" = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.ref" = "assertion.ref"
  }
  attribute_condition = "assertion.repository == '${var.github_repository}'"
  oidc { issuer_uri = "https://token.actions.githubusercontent.com" }
}
resource "google_service_account" "github_actions" {
  project = var.project_id
  account_id = var.github_actions_service_account_id
  display_name = "GitHub Actions CI (WIF)"
}
resource "google_service_account" "gke_workload" {
  project = var.project_id
  account_id = var.gke_workload_service_account_id
  display_name = "Store application workload"
}
resource "google_service_account_iam_member" "github_wif" {
  service_account_id = google_service_account.github_actions.name
  role = "roles/iam.workloadIdentityUser"
  member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_repository}"
}
resource "google_artifact_registry_repository_iam_member" "writer" {
  project = var.project_id
  location = var.region
  repository = var.artifact_repository_id
  role = "roles/artifactregistry.writer"
  member = "serviceAccount:${google_service_account.github_actions.email}"
}
resource "google_secret_manager_secret_iam_member" "sonar_read" {
  project = var.project_id
  secret_id = var.sonar_secret_id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${google_service_account.github_actions.email}"
}
resource "google_project_iam_member" "gke_node_logging" {
  project = var.project_id
  role = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.gke_nodes.email}"
}
resource "google_project_iam_member" "gke_node_monitoring" {
  project = var.project_id
  role = "roles/monitoring.metricWriter"
  member = "serviceAccount:${google_service_account.gke_nodes.email}"
}
resource "google_service_account" "gke_nodes" {
  project = var.project_id
  account_id = "gitops-gke-nodes"
  display_name = "GitOps lab GKE nodes"
}

# Allow the Kubernetes service accounts to impersonate the workload GSA through GKE Workload Identity.
resource "google_service_account_iam_member" "product_api_workload_identity" {
  service_account_id = google_service_account.gke_workload.name
  role = "roles/iam.workloadIdentityUser"
  member = "serviceAccount:${var.project_id}.svc.id.goog[default/product-api]"
}
resource "google_service_account_iam_member" "order_api_workload_identity" {
  service_account_id = google_service_account.gke_workload.name
  role = "roles/iam.workloadIdentityUser"
  member = "serviceAccount:${var.project_id}.svc.id.goog[default/order-api]"
}
