provider "google" {
 # credentials = file("")
  project     = "iti-1-366311"
  region      = "us-centeral1"
}
#gcloud auth application-default login

##################### vpc ###############
resource "google_compute_network" "main-network" {
    name = "main-network"
    auto_create_subnetworks = false

}

############# management subnet ################

resource "google_compute_subnetwork" "management-sub" {
    name = "management-sub"
    ip_cidr_range = "10.0.5.0/24"
    region =  "us-central1"
    network = google_compute_network.main-network.id 
    private_ip_google_access = true
}

############## private subnet #############

resource "google_compute_subnetwork" "cluster-sub" {
    name = "cluster-sub"
    ip_cidr_range = "10.0.99.0/24"
    region =  "us-central1"
    network = google_compute_network.main-network.id 

    secondary_ip_range {
       range_name    = "services-range"
       ip_cidr_range = "192.168.10.0/24"
    }

    secondary_ip_range {
       range_name    = "pod-range"
       ip_cidr_range = "192.168.20.0/24"
    }

}

##########  cloud router ############

resource "google_compute_router" "router" {

    name = "router"
    region = "us-central1"
    network = google_compute_network.main-network.id
    bgp {
        asn = 64514
        advertise_mode = "CUSTOM"
        advertised_groups = ["ALL_SUBNETS"]
    }
}

 #################### router 2 ##########


resource "google_compute_router" "router-2" {

    name = "router-2"
    region = "us-central1"
    network = google_compute_network.main-network.id
    bgp {
        asn = 64514
        advertise_mode = "CUSTOM"
        advertised_groups = ["ALL_SUBNETS"]
    }
}

#################### nat gateway #######



resource "google_compute_router_nat" "nat" {
    name = "nat"
    router = google_compute_router.router.name
    region = "us-central1"

    source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
    nat_ip_allocate_option = "AUTO_ONLY"

    subnetwork {
        name = "management-sub"
        source_ip_ranges_to_nat = ["ALL_IP_RANGES"]

    }
    
   # nat_ips = [google_compute_address.nat.self_link]
}

resource "google_compute_router_nat" "cluster-nat" {
    name = "nat"
    router = google_compute_router.router-2.name
    region = "us-central1"

    source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
    nat_ip_allocate_option = "AUTO_ONLY"

    subnetwork {
        name = "cluster-sub"
        source_ip_ranges_to_nat = ["ALL_IP_RANGES"]

    }
}