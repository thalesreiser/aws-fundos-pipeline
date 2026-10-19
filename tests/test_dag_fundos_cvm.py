"""Integrity checks for the Airflow DAG (RNF-04, RNF-06).

The static checks run everywhere without installing Airflow. The DagBag check runs only
where ``apache-airflow`` is installed; in CI the DAG import is validated inside the
Airflow container (``airflow dags list-import-errors``, job ``airflow``).
"""

from __future__ import annotations

import ast
from pathlib import Path

import pytest

DAG_FILE = Path(__file__).resolve().parents[1] / "airflow" / "dags" / "fundos_cvm.py"


def _tree() -> ast.Module:
    return ast.parse(DAG_FILE.read_text(encoding="utf-8"), filename=str(DAG_FILE))


def test_dag_file_is_valid_python() -> None:
    assert _tree().body


def test_dag_id_is_fundos_cvm() -> None:
    dag_ids = [
        kw.value.value
        for node in ast.walk(_tree())
        if isinstance(node, ast.Call)
        for kw in node.keywords
        if kw.arg == "dag_id" and isinstance(kw.value, ast.Constant)
    ]
    assert dag_ids == ["fundos_cvm"]


def test_dag_has_no_aws_sdk_or_secrets() -> None:
    """Orchestration only: no direct boto3 usage and no hard-coded AWS keys (RNF-03/06)."""
    source = DAG_FILE.read_text(encoding="utf-8")
    imported: set[str] = set()
    for node in ast.walk(_tree()):
        if isinstance(node, ast.Import):
            imported.update(alias.name.split(".")[0] for alias in node.names)
        elif isinstance(node, ast.ImportFrom) and node.module:
            imported.add(node.module.split(".")[0])
    assert "boto3" not in imported
    assert "aws_access_key_id" not in source.lower()
    assert "aws_secret_access_key" not in source.lower()


def test_dagbag_imports_without_errors() -> None:
    # `airflow.models`, not `airflow`: the repository has an `airflow/` folder that imports as a
    # namespace package when the repository root is on sys.path (`python -m pytest`).
    pytest.importorskip("airflow.models")
    from airflow.models import DagBag

    bag = DagBag(dag_folder=str(DAG_FILE.parent), include_examples=False)
    assert bag.import_errors == {}
    assert "fundos_cvm" in bag.dag_ids
