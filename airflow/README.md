# Local Airflow

Apache Airflow **3.3.2** (`apache/airflow:3.3.2-python3.11`) via Docker Compose, to avoid the
continuous cost of MWAA (see [ADR 002](../docs/adr/002-airflow-local-vs-mwaa.md)). RNF-04.

## Services

| Service | Role |
|---|---|
| `postgres` | Metadata database (volume `postgres-db-volume`) |
| `airflow-init` | One-shot: migrates the database and creates the local admin user |
| `airflow-apiserver` | UI and REST API on <http://localhost:8080> (health: `/api/v2/monitor/health`) |
| `airflow-scheduler` | Scheduler with `LocalExecutor` (tasks run inside it) |
| `airflow-dag-processor` | Parses `dags/` |

Trimmed from the official compose: Redis, Celery worker, Flower, triggerer and `airflow-cli`
(details in the header of `docker-compose.yml` and in ADR 002). Plan for about 3 GB of RAM
and 4 GB of disk for the images.

## Prerequisites

- Docker with Compose v2 (Docker Desktop on Windows/macOS) and GNU make
- Optional: AWS CLI v2 with an IAM Identity Center (SSO) profile, only for DAGs that call AWS

## Run

```bash
cp .env.example .env              # optional: local-dev defaults (UID, port, admin user, profile)
make airflow-up                   # starts and waits until every service is healthy
make trigger COMPETENCIA=2026-09  # unpauses and triggers fundos_cvm
make airflow-ps                   # status | make airflow-logs for the last log lines
make airflow-down                 # stop | make airflow-down V=1 also deletes the database
```

UI: <http://localhost:8080>, user/password `airflow`/`airflow` (local-only defaults, override
with `AIRFLOW_ADMIN_USER`/`AIRFLOW_ADMIN_PASSWORD` in `.env`). On Linux set `AIRFLOW_UID` to
`id -u` so files in `airflow/logs/` belong to you.

## AWS credentials (no keys)

No access keys are used anywhere (RNF-03). The host AWS directory is mounted **read-only** at
`/home/airflow/.aws` and the profile is selected by `AWS_PROFILE` (default `portfolio`):

```bash
aws configure sso --profile portfolio   # once
aws sso login --profile portfolio       # whenever the SSO session expires
```

| Host | Directory mounted by default |
|---|---|
| Linux/macOS | `~/.aws` |
| Windows (Docker Desktop) | `%USERPROFILE%\.aws` |

Use `AWS_CONFIG_DIR` in `.env` if it lives elsewhere. If the directory does not exist,
Docker creates it empty and Airflow still starts (this is what happens in CI). Because the
mount is read-only, refresh the SSO session on the host, not inside the containers.

## DAG

`dags/fundos_cvm.py` is a placeholder (tasks only log the reference month) until task 5.2.
It contains orchestration only; transformation code lives in `src/fundos_pipeline` (RNF-06).

## CI

The laptop has no Docker, so the `airflow` job of `.github/workflows/ci.yml` runs
`make airflow-up`, checks the health endpoint, lists the DAG with no import errors, checks
that the SSO profile is resolved without keys, runs `make trigger` and always runs
`make airflow-down V=1`.
