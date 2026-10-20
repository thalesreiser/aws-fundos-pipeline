# 06 - Traceability matrix

| Requirement | Component | Test | Status |
|---|---|---|---|
| RF-01 | `fundos_pipeline/ingestion` | | ⬜ |
| RF-02 | `fundos_pipeline/ingestion` | | ⬜ |
| RF-03 | `fundos_pipeline/transform` | | ⬜ |
| RF-04 | `fundos_pipeline/quality` | | ⬜ |
| RF-05 | `fundos_pipeline/transform` | | ⬜ |
| RF-06 | `infra/terraform` | | ⬜ |
| RF-07 | `airflow/dags/fundos_cvm.py` | | ⬜ |
| RF-08 | `infra/terraform` (SNS) | | ⬜ |
| RF-09 | `notebooks/` | | ⬜ |
| RNF-02 | `infra/terraform` (Budgets) | | ⬜ |
| RNF-03 | `infra/terraform` (IAM, S3) + CI OIDC; Airflow via read-only SSO profile mount | CI job `airflow` (profile resolved, no static keys) | 🚧 |
| RNF-04 | `airflow/docker-compose.yml` (local Airflow); Terraform part pending | CI job `airflow` (`make airflow-up`, health, DAG import, placeholder run); `tests/test_dag_fundos_cvm.py` | 🚧 |

## Change log
| Date | Change | Reason | ADR |
|---|---|---|---|
| 2026-10-17 | Local Airflow 3.3.2 in Docker Compose (LocalExecutor, trimmed official compose), AWS via SSO profile, `airflow` CI job (task 5.1). Real AWS access pending task 1.2 | Avoid MWAA fixed cost (RNF-02, RST-01); reproducible orchestration (RNF-04) | [002](adr/002-airflow-local-vs-mwaa.md) |
| 2026-10-20 | Security hygiene: `SECURITY.md` (private vulnerability reporting), Dependabot for pip, GitHub Actions and Terraform, third-party actions pinned to commit SHAs, CVM ODbL attribution in README and usage policy | Public repository; supply-chain and licensing hygiene (RST-01) | |
