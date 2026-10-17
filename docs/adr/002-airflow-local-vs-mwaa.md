# 002 - Local Airflow vs MWAA

- **Status:** accepted
- **Date:** 2026-10-17

## Context

The pipeline needs an orchestrator with retries, backfill and idempotent re-runs (RF-07),
and the project has a hard cost target of **US$ 5/month or less** (RNF-02) using only
free-tier or predictable-cost services (RST-01). The workload is tiny: one run per reference
month (COMPETENCIA), a few minutes of Lambda and Glue each time.

Amazon MWAA (Managed Workflows for Apache Airflow) bills the environment by the hour while it
exists, plus workers, the metadata database and the mandatory VPC/NAT networking. Even the
smallest environment costs tens of US$ per month, many times the whole budget, regardless of
how often the DAG runs. MWAA Serverless, where available, removes the always-on environment
but is still a newer, region-dependent offering billed per use that adds IAM/VPC setup and
cannot be started for free on demand from a laptop.

The developer laptop has no Docker and limited disk, so the stack must also be verifiable in
CI (same strategy as ADR 006 of the sibling project spark-cnpj-lakehouse).

## Decision

Run **Apache Airflow 3.3.2** locally with **Docker Compose** (`airflow/docker-compose.yml`,
image `apache/airflow:3.3.2-python3.11`, same Python as the project), started with
`make airflow-up` and stopped with `make airflow-down`. The scheduler only calls AWS
services (Lambda, Glue, Athena) that cost nothing while idle.

The compose is the official one for 3.3.2, **trimmed** to fit 8 GB of RAM:

- `LocalExecutor` instead of `CeleryExecutor`: removes Redis, the Celery worker and Flower.
  One run per month does not need distributed workers.
- No triggerer (no deferrable operators yet), no `airflow-cli` service, no example DAGs, no
  `_PIP_ADDITIONAL_REQUIREMENTS`, one API server worker and `parallelism = 4`.
- Remaining services: `postgres`, `airflow-init` (one-shot), `airflow-apiserver` (UI and API
  on port 8080), `airflow-scheduler` and `airflow-dag-processor`.

AWS access uses **no access keys** (RNF-03): the host `~/.aws` directory
(Windows `%USERPROFILE%\.aws`) is mounted **read-only** into the containers and the profile
is chosen with `AWS_PROFILE` (default `portfolio`, IAM Identity Center/SSO). The developer
runs `aws configure sso` and `aws sso login` on the host; the containers only read the
config and the SSO token cache.

## Alternatives considered

| Option | Why not |
|---|---|
| MWAA (provisioned) | Continuous hourly cost far above US$ 5/month (RNF-02, RST-01) |
| MWAA Serverless | Per-use, but new and region-dependent; extra IAM/VPC setup and not runnable offline; worth revisiting if the project ever needs a hosted scheduler |
| Airflow on EC2 | Instance, disk and maintenance costs; patching and security become our job |
| AWS Step Functions (+ EventBridge) | Cheap and serverless, but the project goal includes demonstrating Airflow (DAGs, backfill, retries) |
| Celery layout of the official compose | Needs ~2 GB more RAM (Redis, worker, Flower) with no benefit at this scale |

## Consequences

- Orchestration cost is zero; AWS is only billed for the work actually triggered.
- Airflow runs on the developer machine or in CI, not 24/7: there is no automatic monthly
  schedule in the cloud, which is acceptable because runs are started on demand
  (`make trigger COMPETENCIA=YYYY-MM`).
- Credentials come from the SSO profile of whoever runs it; no keys in the repository, in
  `.env` or in the images. The SSO session must be refreshed on the host (`aws sso login`)
  because the mount is read-only.
- The laptop has no Docker, so the stack is validated in the GitHub Actions `airflow` job
  (start, health check, DAG import, a placeholder run). Real AWS calls from Airflow will be
  proven once the AWS account exists (task 1.2) and the real DAG lands (task 5.2).
- Moving to MWAA later only requires reusing the DAG folder; the DAG keeps orchestration
  separate from transformation code (RNF-06).
