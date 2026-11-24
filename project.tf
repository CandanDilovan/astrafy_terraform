# GCP project and the APIs it needs.
# No billing account is linked: BigQuery then runs in sandbox mode (free tier),
# which is enough for this challenge.

resource "google_project" "this" {
  name       = var.project_id
  project_id = var.project_id

  # Allows `terraform destroy` to delete the project (default would block it).
  # In production, use "PREVENT" to protect against accidental deletion.
  deletion_policy = "DELETE"
}

resource "google_project_service" "bigquery" {
  project = google_project.this.project_id
  service = "bigquery.googleapis.com"

  # Keep the API enabled on destroy: the project is deleted anyway.
  disable_on_destroy = false
}

resource "google_project_service" "iam" {
  project            = google_project.this.project_id
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

# A freshly enabled API takes a while to propagate. Without this pause,
# creating the service account right after enabling IAM fails on the first apply.
resource "time_sleep" "wait_for_iam_api" {
  create_duration = "60s"
  depends_on      = [google_project_service.iam]
}
