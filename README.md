# Bitcoin Cash analytics: infrastructure (Terraform)

Terraform code of the Astrafy Data Engineer take-home challenge (Part 2).
It creates everything the [dbt project](https://github.com/CandanDilovan/astrafy_dbt)
needs. No resource is created by hand.

## What it creates

- A **GCP project** with the BigQuery and IAM APIs.
- Two **BigQuery datasets**, `staging` and `marts`, in `US` (same location as
  the public Bitcoin Cash dataset, required to query it).
- A **service account** `dbt-runner` that can run queries in the project and
  write only in the two datasets (least privilege).
- A **JSON key** for this service account, used by the dbt CI.

## Choices worth knowing

- **No billing account**: BigQuery runs in the free sandbox, which forces a
  60-day expiration on tables (declared in the code to avoid drift).
- **Local state**: a remote GCS bucket would have to exist before Terraform
  runs, i.e. be created by hand, which the challenge forbids.
- **Service account key** instead of Workload Identity Federation, for
  simplicity. WIF would avoid storing a long-lived secret in production.

## Usage

```bash
gcloud auth application-default login
cp terraform.tfvars.example terraform.tfvars   # set a unique project_id
terraform init
terraform apply

# Give the key to the dbt CI (GitHub secret), without printing it
terraform output -raw dbt_service_account_key | gh secret set GCP_SA_KEY -R <owner>/<dbt-repo>
```
