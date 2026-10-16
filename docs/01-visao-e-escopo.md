# 01 - Visão e escopo

**Problema:** disponibilizar, de forma automatizada e confiável, dados públicos de fundos de investimento para análise.

**Objetivo:** construir um pipeline com ingestão, transformação, validação e consulta na AWS, orquestrado por Airflow e provisionado por Terraform.

**Fonte de dados:** Dados Abertos da CVM (informe diário e cadastro de fundos). Confirmar layout e URL atuais antes de começar (R-04).

| Dentro do escopo | Fora do escopo |
|---|---|
| Ingestão incremental, camadas S3, catálogo, qualidade, consulta Athena, IaC, CI/CD, alertas | Streaming, Kubernetes, Airflow gerenciado (MWAA tem custo contínuo) |

## Métricas de sucesso (meta)
- `terraform apply` + execução da DAG em ≤ 30 min
- Reexecução sem duplicar dados
- Custo mensal ≤ US$ 5

## Stakeholders (papéis simulados)
| Papel | Interesse principal |
|---|---|
| Recrutador técnico / gestor | Evidência clara de stack, qualidade e autonomia, em 5 minutos de leitura |
| Engenheiro(a) revisor(a) | Código testado, organizado, reprodutível, com decisões justificadas |
| Analista consumidor(a) | Dados confiáveis, documentados e fáceis de consultar |
| Thales (dev e operador) | Custo baixo, execução reprodutível, manutenção simples |
