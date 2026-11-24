# Values needed by the dbt repository.

output "project_id" {
  description = "ID of the created GCP project (project in the dbt profile)."
  value       = google_project.this.project_id
}

output "dbt_service_account_email" {
  description = "Email of the service account used by dbt."
  value       = google_service_account.dbt.email
}

output "dbt_service_account_key" {
  description = "JSON key of the dbt service account, to store as the GCP_SA_KEY secret of the dbt repository."
  value       = base64decode(google_service_account_key.dbt.private_key)
  sensitive   = true # never printed by plan/apply; read it with: terraform output -raw
}
