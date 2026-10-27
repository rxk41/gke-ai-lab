output "project_number" { value = data.google_project.current.number }
output "gke_node_service_account_email" { value = google_service_account.gke_nodes.email }
output "github_actions_service_account_email" { value = google_service_account.github_actions.email }
output "gke_workload_service_account_email" { value = google_service_account.gke_workload.email }
output "workload_identity_pool_name" { value = google_iam_workload_identity_pool.github.name }
output "workload_identity_provider_name" { value = google_iam_workload_identity_pool_provider.github.name }
output "github_wif_provider_resource_name" { value = "projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${var.workload_identity_pool_id}/providers/${var.workload_identity_provider_id}" }
