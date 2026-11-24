# Input variables. Values are set in terraform.tfvars (git-ignored),
# see terraform.tfvars.example.

variable "project_id" {
  description = "ID of the GCP project to create. Must be globally unique across all of Google Cloud."
  type        = string
}

variable "region" {
  description = "Default region for regional resources. BigQuery datasets use the US multi-region (see bigquery.tf)."
  type        = string
  default     = "us-central1"
}
