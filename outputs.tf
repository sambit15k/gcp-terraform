output "instance_name" {
  value = google_compute_instance.prod_vm.name
}

output "instance_ip" {
  value = google_compute_address.static_ip.address
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/id_rsa ${var.ssh_user}@${google_compute_address.static_ip.address}"
}
