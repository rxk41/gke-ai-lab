project_id        = "k8s-learning-510807"
region            = "us-central1"
zone              = "us-central1-a"
node_count        = 3
machine_type      = "e2-standard-4"
disk_size_gb      = 20
github_repository = "rxk41/gke-GitOps-final"
# Create the sonarcloud-token secret before apply. Database Secret Manager access is optional
# and is not configured until you add a database integration later.
sonar_secret_id               = "sonarcloud-token"
workload_identity_pool_id     = "github-actions-pool-v2"
workload_identity_provider_id = "github-provider-v2"
network                       = "gitops-dev-vpc"
subnetwork                    = "gitops-dev-subnet"