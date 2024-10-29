
resource "google_logging_folder_sink" "folder-error-sink" {
  name   = "${local.source_folder_log_sink_name}"
  description = "Folder Sink para o folder new-infrastructure e filhos"
  folder = local.source_folder_id
  # Can export to pubsub, cloud storage, or bigquery
  destination = "logging.googleapis.com/projects/${local.target_project_id}/locations/global/buckets/${local.target_logging_folder_bucket_name}"
  include_children = true
  
  # Log all WARN or higher severity messages relating to instances
  filter = "severity >= ERROR"
}
module "destination_folder" {
  source                   = "terraform-google-modules/log-export/google//modules/logbucket"
  version                  = "7.8.2"
  project_id               = local.target_project_id
  location                 = "global" # Multi-regional "us"
  name                     = local.target_logging_folder_bucket_name
  retention_days           = 30
  grant_write_permission_on_bkt = true
  enable_analytics         = true
  # Remover o prefixo "serviceAccount:" do writer_identity  logstorage-bucket-error-r3a-monitoring-svcs-hmg-globa
  # log_sink_writer_identity = google_service_account.logsink-custom-sa.email
  log_sink_writer_identity = google_logging_folder_sink.folder-error-sink.writer_identity
}
import {
  to = google_logging_folder_sink.default
  id = "folders/${local.source_folder_id}/sinks/_Default"
}
# Excluindo logs de erro no logsink "_Default"
resource "google_logging_folder_sink" "default" {
  name = "_Default"
  folder = local.source_folder_id
  destination = "logging.googleapis.com/projects/${local.target_project_id}/locations/global/buckets/_Default"
  filter = "NOT \"severity >= ERROR\" AND NOT LOG_ID(\"cloudaudit.googleapis.com/activity\") AND NOT LOG_ID(\"externalaudit.googleapis.com/activity\") AND NOT LOG_ID(\"cloudaudit.googleapis.com/system_event\") AND NOT LOG_ID(\"externalaudit.googleapis.com/system_event\") AND NOT LOG_ID(\"cloudaudit.googleapis.com/access_transparency\") AND NOT LOG_ID(\"externalaudit.googleapis.com/access_transparency\")"
  include_children = true
}
output "log_export_folder-error-sink" {
  value = "SA-------:${google_logging_folder_sink.folder-error-sink.writer_identity}"
  depends_on = [ google_logging_folder_sink.folder-error-sink ]
}
output "log_export_folder_default" {
  value = "SA-------:${google_logging_folder_sink.default.writer_identity}"
  depends_on = [ google_logging_folder_sink.default ]
}