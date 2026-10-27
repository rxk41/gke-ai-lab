
resource "google_container_cluster" "this" {
  project                  = var.project_id
  name                     = var.cluster_name
  location                 = var.zone
  network                  = var.network
  subnetwork               = var.subnetwork
  networking_mode          = "VPC_NATIVE"
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods"
    services_secondary_range_name = "gke-services"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  release_channel {
    channel = "REGULAR"
  }
}

resource "google_container_node_pool" "default" {
  project        = var.project_id
  name           = "app-pool"
  location       = var.zone
  cluster        = google_container_cluster.this.name
  node_count     = var.node_count
  node_locations = [var.zone]

  node_config {
    machine_type    = var.machine_type
    service_account = var.node_service_account
    image_type      = "COS_CONTAINERD"
    disk_type       = "pd-standard"
    disk_size_gb    = var.disk_size_gb

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      environment = "dev"
      managed_by  = "terraform"
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
