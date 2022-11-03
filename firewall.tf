################### firewalls  #############
resource "google_compute_firewall" "allow-ssh" {
    name = "allow-ssh"
    network = google_compute_network.main-network.name

    allow {
        protocol = "tcp"
        ports = ["22"]

    }
    source_ranges = ["35.235.240.0/20"]
}
