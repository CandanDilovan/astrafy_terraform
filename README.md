# Bitcoin Cash analytics: infrastructure (Terraform)

Infrastructure for the Astrafy Data Engineer take-home challenge (Part 2).
It creates everything the dbt project needs to transform the public dataset
`bigquery-public-data.crypto_bitcoin_cash`. **No resource is created by hand.**

## What gets created

| Resource | Name | Why |
|---|---|---|
| GCP project | `var.project_id` | Isolated project for the challenge |
| APIs | BigQuery, IAM | Required by the resources below |
| BigQuery dataset | `staging` (US) | dbt staging table: last 3 months of `transactions` |
| BigQuery dataset | `marts` (US) | dbt data mart: current balance per address |
| Service account | `dbt-runner` | Identity used by dbt (locally and in CI) |
| IAM | `bigquery.jobUser` on the project | Run queries |
| IAM | `bigquery.dataEditor` on `staging` and `marts` only | Write tables, nowhere else |

```
dbt-runner (service account)
   ├─ jobUser ............ project        -> can run queries
   ├─ dataEditor ......... staging        -> can write tables
   ├─ dataEditor ......... marts          -> can write tables
   └─ (public, no grant) . bigquery-public-data.crypto_bitcoin_cash -> can read
```

## Repository layout

```
.
├── versions.tf                # Terraform & provider versions, Google provider
├── variables.tf               # Inputs (project_id, region)
├── project.tf                 # Project + APIs
├── bigquery.tf                # staging & marts datasets
├── iam.tf                     # dbt service account + permissions
└── terraform.tfvars.example   # Template for your own values
```

## Usage

Prerequisites: [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
and the [gcloud CLI](https://cloud.google.com/sdk/docs/install).

```bash
# 1. Let Terraform use your Google account
gcloud auth application-default login

# 2. Set your values (the project ID must be globally unique)
cp terraform.tfvars.example terraform.tfvars

# 3. Deploy
terraform init
terraform plan
terraform apply

# Clean up everything (deletes the project)
terraform destroy
```

## Design choices

- **BigQuery sandbox, no billing account.** The challenge fits in the free tier,
  so no billing account is linked. Consequences: tables expire after 60 days
  (declared in `bigquery.tf` to avoid drift) and storage is capped at 10 GB per
  project.
- **Datasets in `US`.** The public dataset is in the US multi-region and BigQuery
  cannot query across locations, so our datasets must be in the same location.
- **Two datasets, `staging` and `marts`.** One dataset per layer: permissions,
  expiration and lifecycle can be managed per layer.
- **Least privilege.** The service account can run queries in the project but can
  only write in our two datasets (dataset-level grants, not project-level
  `dataEditor`).
- **`_iam_member` resources.** They add one member to a role without overwriting
  the other members, unlike `_iam_binding` / `_iam_policy`.
- **`time_sleep` after enabling the IAM API.** A newly enabled API takes time to
  propagate; without the pause the service account creation fails on the first
  `apply`.
- **`deletion_policy = "DELETE"`.** Makes `terraform destroy` possible for a
  throwaway project. In production: `"PREVENT"`.

## State management

The state is stored **locally** (`terraform.tfstate`, git-ignored, as it can
contain secrets). A remote GCS backend is the standard for team work, but its
bucket must exist *before* Terraform runs, which would mean creating a resource
by hand (forbidden by the challenge). In production, a small bootstrap stack
creates the state bucket once, and every other stack uses
`backend "gcs" { bucket = "..." }`.

## Going further (production)

- Remote state in GCS with locking.
- CI on this repository: `terraform fmt -check` / `validate` / `plan` on pull
  requests, `apply` on merge, first to a dev project then to prod.
- Workload Identity Federation instead of a service account key for GitHub
  Actions (no long-lived secret).
# astrafy_terraform
