data "google_app_engine_default_service_account" "default" {
}
data "google_compute_default_service_account" "default" {
}
data "google_artifact_registry_repository" "container_registry" {
  project       = var.project_id
  location      = var.default_region
  repository_id  = "mr-robot-${var.env}-container-registry"
}