############ standard GKE cluster ###########     gcloud container clusters get-credentials my_gke_cluster

resource "google_container_cluster" "my-gke-cluster" {
  name               = "my-gke-cluster"
  location           = "us-central1"

  remove_default_node_pool = true
  initial_node_count = 2
  
  networking_mode = "VPC_NATIVE"
  network    = google_compute_network.main-network.id
  subnetwork = google_compute_subnetwork.restricted-sub.id

  node_locations = [
        "us-central1-a"
  ]
  addons_config {
        http_load_balancing{
            disabled = false
        }
        horizontal_pod_autoscaling{
            disabled = true
        }
        network_policy_config{
            disabled = false
        }
  }
  release_channel {
        channel = "REGULAR"
  }
  workload_identity_config {
        workload_pool = "iti-1-366311.svc.id.goog"
  }
    

  ip_allocation_policy {
    cluster_secondary_range_name  = "services-range"
    services_secondary_range_name = google_compute_subnetwork.restricted-sub.secondary_ip_range.1.range_name
  }
  master_authorized_networks_config {
        cidr_blocks {
          cidr_block = "10.0.5.0/24"
        } 
    }
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }
 
}


resource "google_container_node_pool" "primary_nodes" {
  name       = "my-node-pool"
  location   = "us-central1"
  cluster    = google_container_cluster.my-gke-cluster.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.cluster_account.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    
    ]
  }
}

############## service  account #################


resource "google_service_account" "cluster_account" {
  account_id   = "service-account-cluster"
  display_name = "Service Account"
}

# resource "google_service_account_key" "mykey" {
#   service_account_id = google_service_account.cluster_account.name
# }

# resource "kubernetes_secret" "google-application-credentials" {
#   metadata {
#     name = "google-application-credentials"
#   }
#   data = {
#     "credentials.json" = base64decode(google_service_account_key.mykey.private_key)
#   }
# }