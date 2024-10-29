terraform {
  backend "gcs" {
    bucket      = "bucket-terraform-shd-southamerica-east1"
    prefix      = "r3a-mr-robot-hmg"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
}
# provider "google" {
#   project = var.project_id
#   region  = var.default_region
# }
# provider "google-beta" {
#   project = var.project_id
#   region  = var.default_region
# }