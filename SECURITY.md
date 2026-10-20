# Security policy

## Supported versions

This is a portfolio project. Only the `main` branch is supported; there are no releases and
no backported fixes.

| Version | Supported |
|---|---|
| `main` | Yes |
| Anything else (old commits, forks) | No |

## Reporting a vulnerability

Please report vulnerabilities **privately** through GitHub private vulnerability reporting:
open the repository **Security** tab and click **Report a vulnerability**.

- Do **not** open a public issue, pull request or discussion for a security problem.
- Include what is affected (file, Terraform resource, DAG or workflow), how to reproduce it and
  the impact you expect.
- Responses are **best effort**: this is a personal project maintained in spare time, so there is
  no guaranteed response or fix time. You will get an acknowledgement once the report is read.

## Scope

In scope:

- The code in this repository: Python ingestion and transformation code, Airflow DAGs, the
  Terraform configuration under `infra/` and the GitHub Actions workflows.
- Secrets or personal data accidentally committed to the repository.

Out of scope:

- The CVM open data portal, AWS itself and any other third-party service or dependency (report
  those to their maintainers; dependency advisories are tracked through Dependabot).
- AWS accounts and deployments run by third parties from this code.

## AWS credentials

- **No AWS account is wired to this repository yet.** CI only runs `terraform fmt`, `init
  -backend=false` and `validate`; it holds no cloud credentials.
- **Never commit AWS credentials** (access keys, session tokens, `~/.aws` files, `terraform.tfvars`
  with secrets or state files). Use your own `.env` (ignored by Git) created from `.env.example`.
- When `terraform plan` is added to CI, it will authenticate through **GitHub OIDC** with a
  short-lived assumed IAM role (planned), never with long-lived access keys stored as secrets.

Pre-commit runs gitleaks, and GitHub secret scanning with push protection is enabled on the
repository.
