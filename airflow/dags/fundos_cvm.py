"""RF-07: ingestion -> silver -> gold DAG for CVM fund data.

Placeholder for task 5.1 (local Airflow, RNF-04): the tasks only log the reference month
(COMPETENCIA, ``YYYY-MM``) so the stack can be validated end to end without AWS calls.
The real orchestration (Lambda, Glue, retries, backfill, idempotency) is task 5.2.
Transformation logic stays in ``src/fundos_pipeline`` (RNF-06); this file only orchestrates.
"""

from __future__ import annotations

import logging
import re
from datetime import datetime

from airflow.sdk import dag, get_current_context, task

log = logging.getLogger(__name__)

COMPETENCIA_PATTERN = re.compile(r"^\d{4}-(0[1-9]|1[0-2])$")


@dag(
    dag_id="fundos_cvm",
    schedule=None,
    start_date=datetime(2026, 1, 1),
    catchup=False,
    params={"competencia": ""},
    tags=["p1", "cvm", "placeholder"],
    doc_md=__doc__,
)
def fundos_cvm() -> None:
    @task
    def resolve_competencia() -> str:
        """Reference month from the run conf, or the month of the run when absent."""
        context = get_current_context()
        competencia = str(context["params"].get("competencia") or "")
        if not competencia:
            competencia = datetime.now().strftime("%Y-%m")
        if not COMPETENCIA_PATTERN.match(competencia):
            raise ValueError(f"COMPETENCIA must be YYYY-MM, got {competencia!r}")
        log.info("COMPETENCIA=%s", competencia)
        return competencia

    @task
    def ingest(competencia: str) -> str:
        log.info("[placeholder] ingest daily report into bronze for %s", competencia)
        return competencia

    @task
    def build_silver(competencia: str) -> str:
        log.info("[placeholder] build silver for %s", competencia)
        return competencia

    @task
    def build_gold(competencia: str) -> None:
        log.info("[placeholder] build gold for %s", competencia)

    build_gold(build_silver(ingest(resolve_competencia())))


fundos_cvm()
