provider "google" {
  project = "new-infra-new"
  region  = "us-central1"
  credentials = "./mykey.json"
}

resource "google_compute_network" "vpc_network" {
  name                    = "my-vpc-network"
  auto_create_subnetworks = true
}

resource "google_compute_subnetwork" "subnet" {
  name          = "my-subnet"
  network       = google_compute_network.vpc_network.name
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"
}

resource "google_compute_firewall" "firewall" {
  name    = "my-firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "vm" {
  name         = "my-vm"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"
  
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }
}

resource "google_compute_target_pool" "pool" {
  name = "my-target-pool"
  instances = [google_compute_instance.vm.self_link]
}

resource "google_compute_forwarding_rule" "rule" {
  name       = "my-forwarding-rule"
  target     = google_compute_target_pool.pool.self_link
  port_range = "80"
  ip_protocol = "TCP"
  region = "us-central1"
}

