module "project_apis" {
  source     = "../../modules/project-apis"
  project_id = var.project_id
}

module "vpc" {
  source     = "../../modules/vpc"
  project_id = var.project_id
  region     = var.region
  depends_on = [module.project_apis]
}

module "iam" {
  source                 = "../../modules/iam"
  project_id             = var.project_id
  github_repository      = var.github_repository
  region                 = var.region
  artifact_repository_id = "gitops-apps"
  sonar_secret_id        = var.sonar_secret_id
  depends_on             = [module.project_apis, module.artifact_registry]
}

module "artifact_registry" {
  source        = "../../modules/artifact-registry"
  project_id    = var.project_id
  region        = var.region
  repository_id = "gitops-apps"
  depends_on    = [module.project_apis]
}

module "gke" {
  source     = "../../modules/gke"
  project_id = var.project_id
  # region               = var.region
  zone                 = var.zone
  cluster_name         = "gitops-dev-gke"
  network              = module.vpc.network_id
  subnetwork           = module.vpc.subnetwork_id
  node_service_account = module.iam.gke_node_service_account_email
  depends_on           = [module.project_apis, module.vpc, module.iam]
}


# Create it manually later, then update application configuration and Terraform references as needed.
