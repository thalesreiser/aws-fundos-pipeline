#!/usr/bin/env bash
# Runs once when the codespace (or local dev container) is created.
set -euo pipefail

command -v make >/dev/null || { sudo apt-get update -qq && sudo apt-get install -y -qq make; }

python -m pip install --quiet --upgrade pip
python -m pip install --quiet -e ".[dev]"
pre-commit install
terraform -chdir=infra/terraform init -backend=false -input=false >/dev/null

[ -f .env ] || cp .env.example .env

# AWS access: use short-lived SSO credentials (aws configure sso), never long-lived keys (RNF-03).
echo "Dev container ready. Next: aws configure sso, then make tf-plan"
