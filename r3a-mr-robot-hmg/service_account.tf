resource "google_service_account" "artifact_registry_sa" {
  account_id   = "artifact-registry-sa-${var.env}"
  display_name = "Artifact Registry Service Account for ${var.env} environment"
  project      = var.project_id
  # Garante que a Conta de Serviço seja criada somente após o Artifact Registry existir
  depends_on = [data.google_artifact_registry_repository.container_registry]
}
resource "google_artifact_registry_repository_iam_member" "artifact_registry_writer" {
  repository = data.google_artifact_registry_repository.container_registry.name
  location   = data.google_artifact_registry_repository.container_registry.location
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.artifact_registry_sa.email}"
  # Garante que as permissões sejam atribuídas após a Conta de Serviço ser criada
  depends_on = [google_service_account.artifact_registry_sa]
}

resource "google_artifact_registry_repository_iam_member" "artifact_registry_reader" {
  repository = data.google_artifact_registry_repository.container_registry.name
  location   = data.google_artifact_registry_repository.container_registry.location
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.artifact_registry_sa.email}"
  # Garante que as permissões sejam atribuídas após a Conta de Serviço ser criada
  depends_on = [google_service_account.artifact_registry_sa]
}

# Opcional: Criação de uma chave para a Conta de Serviço
# resource "google_service_account_key" "artifact_registry_sa_key" {
#   service_account_id = google_service_account.artifact_registry_sa.name
#   public_key_type    = "TYPE_X509_PEM_FILE"
#   keepers = {
#     recreate = timestamp()
#   }
#   # Garante que a chave seja criada após a Conta de Serviço
#   depends_on = [google_service_account.artifact_registry_sa]
# }
# resource "local_file" "artifact_registry_sa_key" {
#   content  = base64decode(google_service_account_key.artifact_registry_sa_key.private_key)
#   filename = "serviceaccount.json"
#   # Garante que a chave seja criada após a Conta de Serviço
#   depends_on = [google_service_account_key.artifact_registry_sa_key]
# }