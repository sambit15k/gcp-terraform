variable "project" {
  description = "Google Cloud project ID"
  type        = string
}

variable "region" {
  description = "Region"
  default     = "us-central1"
}

variable "zone" {
  description = "Zone"
  default     = "us-central1-a"
}

variable "ssh_user" {
  description = "SSH username"
  default     = "ubuntu"
}

variable "ssh_key_path" {
  description = "Path to your public SSH key (e.g., ~/.ssh/id_rsa.pub)"
  default     = "ssh_key.txt"
}

variable "domain_name" {
  description = "Domain name for TLS (leave empty if not using)"
  default     = ""
}

variable "preemptible" {
  description = "Use preemptible instance?"
  type        = bool
  default     = false
}

variable "allowed_ssh_ranges" {
  description = "List of IP ranges allowed to SSH into the instance"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Change this to your IP range for security
}
