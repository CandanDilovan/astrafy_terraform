# BigQuery datasets written by dbt: one for staging tables, one for data marts.
#
# - location = "US": the public dataset bigquery-public-data.crypto_bitcoin_cash
#   is in the US multi-region and BigQuery cannot query across locations.
# - Expirations: the BigQuery sandbox (no billing) forces a 60-day expiration
#   on tables and partitions. Declaring it here keeps Terraform in sync
#   with what GCP applies, otherwise every plan shows a diff (drift).

resource "google_bigquery_dataset" "staging" {
  project                    = google_project.this.project_id
  dataset_id                 = "staging"
  location                   = "US"
  delete_contents_on_destroy = true # allow destroy even if dbt created tables

  default_table_expiration_ms     = 5184000000 # 60 days (sandbox limit)
  default_partition_expiration_ms = 5184000000

  depends_on = [google_project_service.bigquery]
}

resource "google_bigquery_dataset" "marts" {
  project                    = google_project.this.project_id
  dataset_id                 = "marts"
  location                   = "US"
  delete_contents_on_destroy = true

  default_table_expiration_ms     = 5184000000
  default_partition_expiration_ms = 5184000000

  depends_on = [google_project_service.bigquery]
}
