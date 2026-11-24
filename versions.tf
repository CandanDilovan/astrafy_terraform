# Terraform and provider versions, and the Google provider configuration.
# Authentication uses Application Default Credentials:
#   gcloud auth application-default login

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    # GCP resources (project, BigQuery, IAM)
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0, < 8.0"
    }
    # Only used to wait for the IAM API to propagate (see project.tf)
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
  }
}

provider "google" {
  region = var.region
}
