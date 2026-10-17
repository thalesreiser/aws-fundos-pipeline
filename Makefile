COMPETENCIA ?= $(shell date +%Y-%m)
TF = terraform -chdir=infra/terraform
# Root .env (optional, see .env.example) feeds the compose variables
AIRFLOW_ENV_FILE := $(if $(wildcard .env),--env-file .env,)
AIRFLOW = docker compose $(AIRFLOW_ENV_FILE) -f airflow/docker-compose.yml
AIRFLOW_WAIT_TIMEOUT ?= 300

.PHONY: install lint fmt test tf-init tf-plan tf-apply tf-destroy airflow-up airflow-down airflow-ps \n	airflow-logs trigger

install:
	pip install -e ".[dev]" && pre-commit install

lint:
	ruff check src tests airflow && black --check src tests airflow && mypy src

fmt:
	ruff check --fix src tests airflow && black src tests airflow

test:
	pytest -m "not integration"

tf-init:
	$(TF) init

tf-plan:
	$(TF) fmt -check && $(TF) validate && $(TF) plan

tf-apply:
	$(TF) apply

tf-destroy:
	$(TF) destroy

airflow-up:  ## RNF-04: start local Airflow and wait until every service is healthy
	$(AIRFLOW) up -d --wait --wait-timeout $(AIRFLOW_WAIT_TIMEOUT)
	@echo "Airflow UI: http://localhost:$${AIRFLOW_PORT:-8080}"

airflow-down:  ## stop Airflow; V=1 also removes the volumes (metadata database)
	$(AIRFLOW) down $(if $(V),--volumes,)

airflow-ps:
	$(AIRFLOW) ps

airflow-logs:
	$(AIRFLOW) logs --tail 200

trigger:  ## RF-07
	$(AIRFLOW) exec -T airflow-scheduler airflow dags unpause fundos_cvm
	$(AIRFLOW) exec -T airflow-scheduler airflow dags trigger fundos_cvm -c '{"competencia": "$(COMPETENCIA)"}'
