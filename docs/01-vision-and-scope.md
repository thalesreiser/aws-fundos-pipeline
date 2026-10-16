# 01 - Vision and scope

**Problem:** make public investment fund data available for analysis in an automated and reliable way.

**Goal:** build a pipeline with ingestion, transformation, validation and querying on AWS, orchestrated by Airflow and provisioned with Terraform.

**Data source:** CVM (Brazilian Securities Commission) open data: daily fund reports and the fund registry. Confirm the current layout and URL before starting (R-04).

| In scope | Out of scope |
|---|---|
| Incremental ingestion, S3 layers, catalog, data quality, Athena queries, IaC, CI/CD, alerts | Streaming, Kubernetes, managed Airflow (MWAA has a continuous cost) |

## Success metrics (targets)
- `terraform apply` + DAG run in 30 min or less
- Re-running does not duplicate data
- Monthly cost of US$ 5 or less

## Stakeholders (simulated roles)
| Role | Main interest |
|---|---|
| Technical recruiter / manager | Clear evidence of stack, quality and autonomy within 5 minutes of reading |
| Code reviewer (engineer) | Tested, organized, reproducible code with justified decisions |
| Data consumer (analyst) | Reliable, documented data that is easy to query |
| Thales (developer and operator) | Low cost, reproducible runs, simple maintenance |
