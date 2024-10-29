resource "google_artifact_registry_repository" "container_registry" {
  repository_id = "mr-robot-${var.env}-container-registry"
  location = var.default_region
  format   = "DOCKER"
  project  = var.project_id
  description = "Container Registry for mr-robot in ${var.env} environment."
  labels = {
    env     = var.env
    purpose = "container-registry"
  }
}