
data "google_compute_image" "ubuntu" {
  family  = "ubuntu-minimal-2404-lts-amd64"
  project = "ubuntu-os-cloud"
}

resource "random_id" "instance_id" {
  byte_length = 4
}

resource "google_compute_address" "static_ip" {
  name   = "prod-vm-ip"
  region = var.region
}

resource "google_compute_instance" "prod_vm" {
  name         = "vm-${random_id.instance_id.hex}"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
      type  = "pd-ssd"
      size  = 20
    }
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get dist-upgrade -y
    apt-get install -y apache2 certbot python3-certbot-apache ufw

    # Allow HTTP and HTTPS via firewall (ufw)
    ufw allow OpenSSH
    ufw allow 'Apache Full'
    ufw --force enable

    # Replace this with your domain
    DOMAIN_NAME="${var.domain_name}"

    # Configure HTTPS with Certbot if domain is set
    if [ ! -z "$DOMAIN_NAME" ]; then
      certbot --apache -d "$DOMAIN_NAME" --non-interactive --agree-tos -m admin@$DOMAIN_NAME
    fi

    echo '<!doctype html><html><body><h1>Hello from secure Terraform VM!</h1></body></html>' > /var/www/html/index.html
    systemctl restart apache2
  EOT

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_key_path)}"
  }

  scheduling {
    preemptible        = var.preemptible
    automatic_restart  = false
    on_host_maintenance = "TERMINATE"
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }

  tags = ["http-server", "https-server"]
}

resource "google_compute_firewall" "allow_http_https_ssh" {
  name    = "allow-http-https-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = var.allowed_ssh_ranges
  target_tags   = ["http-server", "https-server"]
}
