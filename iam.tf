# Service account used by dbt (locally and in GitHub Actions) and its permissions.
#
# Least privilege:
# - jobUser on the project: allowed to run queries (BigQuery jobs).
# - dataEditor on our two datasets only: allowed to create/replace tables there,
#   and nowhere else.
# Reading bigquery-public-data needs no grant: it is public.
#
# *_iam_member resources ADD one member to a role without touching the other
# members (unlike *_iam_binding / *_iam_policy, which replace them).

locals {
  dbt = "serviceAccount:${google_service_account.dbt.email}"
}

resource "google_service_account" "dbt" {
  project      = google_project.this.project_id
  account_id   = "dbt-runner"
  display_name = "dbt runner"

  depends_on = [time_sleep.wait_for_iam_api]
}

resource "google_project_iam_member" "dbt_run_queries" {
  project = google_project.this.project_id
  role    = "roles/bigquery.jobUser"
  member  = local.dbt
}

resource "google_bigquery_dataset_iam_member" "dbt_staging" {
  project    = google_project.this.project_id
  dataset_id = google_bigquery_dataset.staging.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = local.dbt
}

resource "google_bigquery_dataset_iam_member" "dbt_marts" {
  project    = google_project.this.project_id
  dataset_id = google_bigquery_dataset.marts.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = local.dbt
}

# JSON key of the service account, used by GitHub Actions to authenticate.
# Created by Terraform (no manual resource). The private key is stored in the
# local state, which is git-ignored. Workload Identity Federation would avoid
# this long-lived secret in production (see README).
resource "google_service_account_key" "dbt" {
  service_account_id = google_service_account.dbt.name
}
