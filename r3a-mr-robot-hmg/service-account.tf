# module "sa_monitoing_svcs" {
#   source     = "terraform-google-modules/service-accounts/google"
#   version    = "~> 4.0"
#   project_id = var.project_id
#   prefix     = ""
#   names      = ["sa-mr-robot-${var.env}"]
#   project_roles = [
#     "${var.project_id}=>roles/cloudbuild.builds.builder",
#     "${var.project_id}=>roles/cloudfunctions.developer",
#     "${var.project_id}=>roles/secretmanager.secretAccessor",
#     "${var.project_id}=>roles/iam.serviceAccountUser",
#     "${var.project_id}=>roles/servicemanagement.admin",
#     "${var.project_id}=>roles/serviceusage.serviceUsageAdmin",
#     "${var.project_id}=>roles/logging.logWriter",
#     "${var.project_id}=>roles/logging.bucketWriter",
#   ]
# }