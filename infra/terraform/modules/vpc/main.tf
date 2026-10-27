resource "google_compute_network" "this" {
  project = var.project_id
  name = var.network_name
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "this" {
  project = var.project_id
  name = var.subnetwork_name
  region = var.region
  network = google_compute_network.this.id
  ip_cidr_range = "10.10.0.0/20"
  secondary_ip_range {
    range_name = "gke-pods"
    ip_cidr_range = "10.20.0.0/16"
  }
  secondary_ip_range {
    range_name = "gke-services"
    ip_cidr_range = "10.30.0.0/20"
  }
}
resource "google_compute_global_address" "private_services" {
  project = var.project_id
  name = "gitops-private-services"
  purpose = "VPC_PEERING"
  address_type = "INTERNAL"
  prefix_length = 16
  network = google_compute_network.this.id
}
resource "google_service_networking_connection" "private_vpc_connection" {
  network = google_compute_network.this.id
  service = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_services.name]
}
