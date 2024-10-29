# Utilizando import ao invés do data. Apenas uma referência para conhecimento técnico
# Reduzindo a retenção do bucket _Default para 1 dias no projeto r3a-mr-robot-hmg
import {
  id = "projects/${var.project_id}/locations/global/buckets/_Default"
  to = google_logging_project_bucket_config.default
}
resource "google_logging_project_bucket_config" "default" {
  bucket_id = "_Default"
  location = "global"
  project   = var.project_id
  retention_days = 1  # Reduzindo a retenção para o mínimo possível (1 dia)
  enable_analytics = true
}
import {
  to = google_logging_project_sink.default
  id = "projects/${var.project_id}/sinks/_Default"
}
# Excluindo logs de erro no logsink "_Default"
resource "google_logging_project_sink" "default" {
  name = "_Default"
  project = var.project_id
  destination = "logging.googleapis.com/projects/${local.target_project_id}/locations/global/buckets/_Default"
  filter = "NOT \"severity >= ERROR\" AND NOT LOG_ID(\"cloudaudit.googleapis.com/activity\") AND NOT LOG_ID(\"externalaudit.googleapis.com/activity\") AND NOT LOG_ID(\"cloudaudit.googleapis.com/system_event\") AND NOT LOG_ID(\"externalaudit.googleapis.com/system_event\") AND NOT LOG_ID(\"cloudaudit.googleapis.com/access_transparency\") AND NOT LOG_ID(\"externalaudit.googleapis.com/access_transparency\")"
  unique_writer_identity = true
}
output "sa_cloudlogs_id" {
  value = "SA-------:${local.sa_cloudlogs_email}"
}
# Create a sink that uses user-managed service account
resource "google_logging_project_sink" "logsink_error" {
  name = "${local.source_log_sink_name}"

  # Can export to log bucket in another project
  destination = "logging.googleapis.com/projects/${local.target_project_id}/locations/global/buckets/${local.target_logstorage_bucket_name}"

  # Log all WARN or higher severity messages relating to instances
  filter = "severity >= ERROR"

  unique_writer_identity = true

  # Use a user-managed service account
  # custom_writer_identity = "serviceAccount:${local.sa_cloudlogs_email}"
  # depends_on = [ google_project_iam_member.custom-sa-logbucket-binding ]
}
resource "google_project_iam_member" "custom-sa-logbucket-binding" {
  for_each = var.writer_identity_roles
    project = local.target_project_id # Destination project ID
    role = each.value
    member  = "serviceAccount:${local.sa_cloudlogs_email}"
}
resource "google_project_iam_member" "unique-sa-logbucket-binding" {
  for_each = var.writer_identity_roles
    project = local.target_project_id # Destination project ID
    role = each.value
    member  = google_logging_project_sink.logsink_error.writer_identity
}

variable "writer_identity_roles" {
  description = "Permissions for the log bucket"
  type        = set(string)
  default     = ["roles/logging.bucketWriter", "roles/logging.logWriter"]
}
output "log_export_error-sink" {
  value = "SA-------:${google_logging_project_sink.logsink_error.writer_identity}"
  # depends_on = [ google_logging_project_sink.logsink_error ]
}
output "log_export_default" {
  value = "SA-------:${google_logging_project_sink.default.writer_identity}"
  # depends_on = [ google_logging_project_sink.default ]
}
