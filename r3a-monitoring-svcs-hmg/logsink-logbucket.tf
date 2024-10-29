resource "google_logging_project_sink" "logsink_error" {
  name = "${local.source_log_sink_name}"

  # Can export to log bucket in another project
  destination = "logging.googleapis.com/projects/${local.target_project_id}/locations/global/buckets/${local.target_logstorage_bucket_name}"

  # Log all WARN or higher severity messages relating to instances
  filter = "severity >= ERROR"

  unique_writer_identity = false

  # Use a user-managed service account
  # custom_writer_identity = "serviceAccount:${local.sa_cloudlogs_email}"
  # depends_on = [ google_project_iam_member.custom-sa-logbucket-binding ]
}
module "destination" {
  source                   = "terraform-google-modules/log-export/google//modules/logbucket"
  version                  = "9.0.0"
  project_id               = local.target_project_id
  location                 = "global" # Multi-regional "us"
  name                     = local.target_logstorage_bucket_name
  retention_days           = 30
  grant_write_permission_on_bkt = true
  enable_analytics         = true
  # Remover o prefixo "serviceAccount:" do writer_identity  logstorage-bucket-error-r3a-monitoring-svcs-hmg-globa
  # log_sink_writer_identity = "serviceAccount:${module.log_export.writer_identity}"
  log_sink_writer_identity = "serviceAccount:cloud-logs@system.gserviceaccount.com"
}
# Utilizando import ao invés do data. Apenas uma referência para conhecimento técnico
import {
  to = google_logging_project_sink.default
  id = "projects/${var.project_id}/sinks/_Default"
}
# data google_logging_project_sink "default" {
#   id = "projects/${var.project_id}/sinks/_Default"
# }
# Excluindo logs de erro no logsink "_Default"
resource "google_logging_project_sink" "default" {
  name = "_Default"
  project = var.project_id
  destination = "logging.googleapis.com/projects/${local.target_project_id}/locations/global/buckets/_Default"
  filter = "NOT \"severity >= ERROR\" AND NOT LOG_ID(\"cloudaudit.googleapis.com/activity\") AND NOT LOG_ID(\"externalaudit.googleapis.com/activity\") AND NOT LOG_ID(\"cloudaudit.googleapis.com/system_event\") AND NOT LOG_ID(\"externalaudit.googleapis.com/system_event\") AND NOT LOG_ID(\"cloudaudit.googleapis.com/access_transparency\") AND NOT LOG_ID(\"externalaudit.googleapis.com/access_transparency\")"
  unique_writer_identity = true
}
import {
  id = "projects/${var.project_id}/locations/global/buckets/_Default"
  to = google_logging_project_bucket_config.default
}
resource "google_logging_project_bucket_config" "default" {
  bucket_id = "_Default"
  location = "global"
  project   = var.project_id
  retention_days = 30
  enable_analytics = true
}
output "log_export_error-sink" {
  value = "SA-------:${google_logging_project_sink.logsink_error.writer_identity}"
  depends_on = [ google_logging_project_sink.logsink_error ]
}
output "log_export_default" {
  value = "SA-------:${google_logging_project_sink.default.writer_identity}"
  depends_on = [ google_logging_project_sink.default ]
}
