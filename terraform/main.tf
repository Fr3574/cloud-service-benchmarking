provider "google" {
  credentials = file("bold-crow-375215-e25bea0247d0.json")

  project = "bold-crow-375215"
  region  = "europe-west3"
  zone    = "europe-west3-c"
}

#####################################################

# Allow traffic between VMs
resource "google_compute_firewall" "allow_traffic" {
  name = "allow-traffic"
  network = "default"

  allow {
    protocol = "all"
  }

  source_tags = ["client", "sut", "database"]
  target_tags = ["client", "sut", "database"]
}

#####################################################

# Create three VMs
resource "google_compute_instance" "client" {
  name         = "client"
  machine_type = "e2-standard-8"
  boot_disk {
    initialize_params {
	  size = 40
      image = "ubuntu-2204-jammy-v20221101a"
    }
  }

  network_interface {
    network = "default"
    access_config {
      # Include this section to give the VM an external IP address
    }
  }
  metadata = {
    startup-script = "${file("startup_client.sh")}"
  }
}

resource "google_compute_instance" "sut" {
  name         = var.sut
  machine_type = "e2-standard-2"
  boot_disk {
    initialize_params {
	  size = 40
      image = "ubuntu-2204-jammy-v20221101a"
    }
  }

  network_interface {
    network = "default"
    access_config {
      # Include this section to give the VM an external IP address
    }
  }
  metadata = {
    startup-script = "${file("startup_${var.sut}.sh")}"
  }
}

resource "google_compute_instance" "database" {
  name = var.sut == "jaeger" ? "elasticsearch" : "gcs"
  machine_type = "e2-standard-4"
  boot_disk {
    initialize_params {
	  size = 40
      image = "ubuntu-2204-jammy-v20221101a"
    }
  }

  network_interface {
    network = "default"
    access_config {
      # Include this section to give the VM an external IP address
    }
  }
  metadata = {
    startup-script = "${file("startup_${var.sut == "jaeger" ? "elasticsearch" : "gcs"}.sh")}"
  }
}
