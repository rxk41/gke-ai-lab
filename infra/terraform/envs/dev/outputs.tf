output "gke_cluster_name" { value = module.gke.cluster_name }
output "gke_zone" { value = var.zone }
output "artifact_registry_repository" { value = module.artifact_registry.repository_id }
output "artifact_registry_url" { value = module.artifact_registry.repository_url }
output "gke_node_service_account_email" { value = module.iam.gke_node_service_account_email }
output "github_actions_service_account_email" { value = module.iam.github_actions_service_account_email }
output "gke_workload_service_account_email" { value = module.iam.gke_workload_service_account_email }
output "github_wif_provider_resource_name" { value = module.iam.github_wif_provider_resource_name }
