# aws-fundos-pipeline

Pipeline de dados orquestrado na **AWS** com **Terraform** (IaC) e **CI/CD**, sobre os Dados Abertos da CVM (informe diário e cadastro de fundos).

> Status: 🚧 em desenvolvimento (Épico 1: Fundações e conta AWS)

## Problema
Disponibilizar, de forma automatizada e confiável, dados públicos de fundos de investimento para análise.

## Arquitetura
```mermaid
flowchart LR
  AF[Airflow local DAG] -->|orquestra| L[Lambda: ingestão]
  CVM[CVM dados abertos] --> L
  L --> B[(S3 Bronze)]
  B -->|Glue job: Parquet + validação| S[(S3 Silver)]
  B -->|inválidos| Q[(S3 Quarantine)]
  S -->|Glue job: agregações| G[(S3 Gold)]
  G --> C[Glue Data Catalog] --> A[Athena] --> N[Notebook / consumo]
  AF -->|falha| SNS[SNS: e-mail]
  GH[GitHub Actions] -->|valida e aplica| TF[Terraform]
```

## Como rodar (3 comandos)
```bash
make tf-apply                   # provisiona a infraestrutura (Terraform)
make airflow-up                 # sobe o Airflow local
make trigger COMPETENCIA=2026-09
```
Ao terminar a sessão: `make tf-destroy` (R-02: evitar custo inesperado).

## Resultados medidos
_A preencher: tempo da DAG, custo mensal real (meta ≤ US$ 5)._

## Decisões
Ver [`docs/adr/`](docs/adr/).

## Limitações
_A preencher._
