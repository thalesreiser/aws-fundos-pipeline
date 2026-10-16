COMPETENCIA ?= $(shell date +%Y-%m)
TF = terraform -chdir=infra/terraform
AIRFLOW = docker compose -f airflow/docker-compose.yml

.PHONY: install lint fmt test tf-init tf-plan tf-apply tf-destroy airflow-up airflow-down trigger

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

airflow-up:
	$(AIRFLOW) up -d

airflow-down:
	$(AIRFLOW) down

trigger:  ## RF-07
	$(AIRFLOW) exec airflow-scheduler airflow dags trigger fundos_cvm -c '{"competencia": "$(COMPETENCIA)"}'
