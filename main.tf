resource "random_id" "instance_id" {
  byte_length = 8
}

resource "google_compute_instance" "default" {
#   name         = "vm-${random_id.instance_id.hex}"
  # count        = 1
  name         = "ubuntu-server"
  machine_type = "n1-custom-4-4096"
  zone         = "us-central1-a"
  

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      type  = "pd-ssd"
      size  = 20
    }
  }


  metadata_startup_script = "sudo apt-get update -y  && sudo apt-get upgrade -y && sudo apt autoremove -y && sudo apt-get install apache2 -y && echo '<!doctype html><html><body><h1>Hello from Terraform on Google Cloud!</h1></body></html>' | sudo tee /var/www/html/index.html"

 metadata = {
    ssh-keys = "sambit:${file("sambit.pub")}"
  }

  scheduling {
  preemptible = true
  automatic_restart = false
  on_host_maintenance = false
  }

  network_interface {
    network = "default"

    access_config {
      // Include this section to give the VM an external ip address
    }
  }

  // Apply the firewall rule to allow external IPs to access this instance
  tags = ["http-server"]
}

resource "google_compute_firewall" "http-server" {
  name    = "default-allow-http"
  network = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "111" , "8080"]
  }

  // Allow traffic from everywhere to instances with an http-server tag
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}


output "Instance-ip" {
  value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
}