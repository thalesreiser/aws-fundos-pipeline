# 02 - Analysis and prioritization (MoSCoW)

## Functional requirements
| ID | Requirement | Prio. | Acceptance criterion | Verification |
|---|---|---|---|---|
| RF-01 | Ingest the daily report per reference month via Lambda into the bronze layer (S3) | M | Given a reference month, then the raw file exists in `bronze/informe_diario/ano=/mes=/` | Integration test |
| RF-02 | Ingest the fund registry | M | Then the latest registry is in `bronze/cadastro/` with its load date | Integration test |
| RF-03 | Convert to Parquet partitioned by year/month in the silver layer | M | Then silver contains the same valid rows as bronze, typed | Row count and schema |
| RF-04 | Validate quality (schema, nulls, duplicates, ranges) and send invalid records to quarantine | M | Given an invalid record, then it goes to `quarantine/` and does not enter silver | Unit tests |
| RF-05 | Build gold: net assets, net inflows and share value change per fund/month | M | Then gold totals reconcile with silver | Reconciliation query |
| RF-06 | Expose tables and views in Athena via the Glue Data Catalog | M | Then `SELECT` on gold works through Athena | Manual test and script |
| RF-07 | Orchestrate with an Airflow DAG (retries, backfill, idempotency) | M | Re-running the same reference month does not change the result | Idempotency test |
| RF-08 | Notify failures by e-mail (SNS) | S | Given a forced failure, then an alert arrives | Manual test |
| RF-09 | Example notebook consuming gold | C | Then the notebook runs end to end | Execution |

## Non-functional requirements, rules and constraints
| ID | Type | Description |
|---|---|---|
| RNF-01 | Idempotency | Reprocessing a reference month produces an identical result (partition overwrite) |
| RNF-02 | Cost | Target of US$ 5/month or less, with AWS Budgets and an alert at 80% |
| RNF-03 | Security | Least-privilege IAM, encrypted S3 with public access blocked, no credentials in the repository (OIDC in GitHub Actions) |
| RNF-04 | Reproducibility | Infrastructure 100% in Terraform, local Airflow via Docker Compose |
| RNF-05 | Observability | Structured logs and basic metrics in CloudWatch |
| RNF-06 | Maintainability | Transformation code separated from orchestration code |
| RN-01 | Business rule | The daily report key is fund CNPJ + reference date |
| RST-01 | Constraint | Only free-tier or predictable-cost services |

## Risks
| ID | Risk | Prob. | Impact | Mitigation |
|---|---|---|---|---|
| R-01 | Scope grows and the project is never finished | High | High | Strict MoSCoW; "Could" only after all "Must" items |
| R-02 | Unexpected AWS cost | Medium | Medium | AWS Budgets alert, free tier, `terraform destroy` at the end of each session |
| R-03 | Lack of time | High | High | Incremental delivery: every epic produces something publishable |
| R-04 | Open data changes format or URL | Medium | Medium | Parameterized download and a versioned sample for tests |
| R-P1-01 | Glue has a minimum cost per run | — | — | Few jobs, minimum workers, on-demand runs |
| R-P1-02 | IAM complexity blocks progress | — | — | Start with broad policies in a test environment and tighten them in task 2.2 |
