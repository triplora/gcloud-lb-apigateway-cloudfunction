output "app_default_account" {
  value = data.google_app_engine_default_service_account.default.email
}
output "compute_default_account" {
  value = data.google_compute_default_service_account.default.email
}
output "artifact_registry_service_account_email" {
  description = "Email da Conta de Serviço do Artifact Registry"
  value       = google_service_account.artifact_registry_sa.email
}

# output "artifact_registry_service_account_key" {
#   description = "Chave JSON da Conta de Serviço do Artifact Registry"
#   value       = google_service_account_key.artifact_registry_sa_key.private_key
#   sensitive   = true
# }