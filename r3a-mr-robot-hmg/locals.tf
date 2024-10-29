locals {
  source_project_id                 = var.project_id
  # source_project_name     = replace(local.source_project_id, "-", "_")
  source_project_name               = local.source_project_id
  source_log_sink_name              = "logsink-er-${local.source_project_name}-${var.default_region}"
  target_project_id                 = "r3a-monitoring-svcs-${var.env}"
  target_cloudstorage_bucket_name   = "stor-bkt-er-${local.target_project_id}-global"
  target_logstorage_bucket_name     = "log-bkt-er-${local.target_project_id}-global"
  target_logging_folder_sink_name   = "folder-bkt-er-${local.target_project_id}-global"
  sa_cloudlogs_id                   = "sa-cloud-logs-${var.env}"
  sa_cloudlogs_email                   = "cloud-logs@system.gserviceaccount.com"
}