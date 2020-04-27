provider "google" {
  credentials = file("google-93274b98dc61.json")
  project     = "gcp-sam"
  region      = "us-central1"
}