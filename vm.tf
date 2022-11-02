##################### private management vm ################

resource "google_compute_instance" "private-vm" {
    
    name = "private-vm"
    machine_type = "e2-medium"
    zone ="us-central1-a"
    #tags = "private"
    description = "this instance to controll and secure follow to  my container cluster"
    allow_stopping_for_update = true

    boot_disk {
      initialize_params {
        image = "debian-cloud/debian-11"
        labels = {
           my_label = "value"
        }
      }  
    }
    
    

    network_interface {
       network = "main-network"
       subnetwork = "management-sub"
    }
    service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
    }
}

################ service account ###################

resource "google_service_account" "default" {

  account_id   = "service-account-vm-33"
  display_name = "Service Account"
}
resource "google_project_iam_binding" "iam-admin" {
 project = "iti-1-366311"
 role = "roles/container.admin"
 
 members = [
 "serviceAccount:${google_service_account.default.email}",
 ]
}