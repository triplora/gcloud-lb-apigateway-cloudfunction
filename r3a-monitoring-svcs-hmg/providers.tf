terraform {
  backend "gcs" {
    bucket      = "bucket-terraform-shd-southamerica-east1"
    prefix      = "r3a-monitoring-svcs-hmg"
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