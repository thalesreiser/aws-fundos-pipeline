# 02 - Análise e priorização (MoSCoW)

## Requisitos funcionais
| ID | Requisito | Prior. | Critério de aceite | Verificação |
|---|---|---|---|---|
| RF-01 | Ingerir o informe diário por competência via Lambda para a camada bronze (S3) | M | Dada uma competência, então o arquivo bruto existe em `bronze/informe_diario/ano=/mes=/` | Teste de integração |
| RF-02 | Ingerir o cadastro de fundos | M | Então o cadastro mais recente está em `bronze/cadastro/` com data de carga | Teste de integração |
| RF-03 | Converter para Parquet particionado por ano/mês na camada silver | M | Então a silver contém as mesmas linhas válidas da bronze, tipadas | Contagem e schema |
| RF-04 | Validar qualidade (schema, nulos, duplicidade, faixas) e enviar inválidos para quarentena | M | Dado um registro inválido, então ele vai para `quarantine/` e não entra na silver | Testes unitários |
| RF-05 | Gerar gold: patrimônio líquido, captação líquida e variação de cota por fundo/mês | M | Então os totais da gold reconciliam com a silver | Consulta de reconciliação |
| RF-06 | Expor tabelas e views no Athena via Glue Data Catalog | M | Então `SELECT` na gold funciona via Athena | Teste manual e script |
| RF-07 | Orquestrar com DAG Airflow (retries, backfill, idempotência) | M | Reexecutar a mesma competência não altera o resultado | Teste de idempotência |
| RF-08 | Notificar falhas por e-mail (SNS) | S | Dada uma falha forçada, então chega alerta | Teste manual |
| RF-09 | Notebook de exemplo consumindo a gold | C | Então o notebook roda ponta a ponta | Execução |

## Requisitos não funcionais, regras e restrições
| ID | Tipo | Descrição |
|---|---|---|
| RNF-01 | Idempotência | Reprocessar uma competência produz resultado idêntico (sobrescrita de partição) |
| RNF-02 | Custo | Meta ≤ US$ 5/mês, com AWS Budgets e alerta em 80% |
| RNF-03 | Segurança | IAM com menor privilégio, S3 criptografado e com bloqueio de acesso público, sem credenciais no repositório (OIDC no GitHub Actions) |
| RNF-04 | Reprodutibilidade | Infra 100% em Terraform, Airflow local via Docker Compose |
| RNF-05 | Observabilidade | Logs estruturados e métricas básicas no CloudWatch |
| RNF-06 | Manutenibilidade | Código de transformação separado do código de orquestração |
| RN-01 | Regra | A chave do informe é CNPJ do fundo + data de competência |
| RST-01 | Restrição | Somente serviços dentro do free tier ou de custo previsível |

## Riscos
| ID | Risco | Prob. | Impacto | Mitigação |
|---|---|---|---|---|
| R-01 | Escopo crescer e o projeto não terminar | Alta | Alto | MoSCoW rígido; "Could" só após todos os "Must" |
| R-02 | Custo inesperado na AWS | Média | Médio | AWS Budgets com alerta, free tier, `terraform destroy` ao fim de cada sessão |
| R-03 | Falta de tempo | Alta | Alto | Entrega incremental: cada épico gera algo publicável |
| R-04 | Dados abertos mudarem de formato ou URL | Média | Médio | Script de download parametrizado e amostra versionada |
| R-P1-01 | Glue ter custo mínimo por execução | — | — | Poucos jobs, workers mínimos, execução sob demanda |
| R-P1-02 | Complexidade de IAM travar o progresso | — | — | Começar com policies amplas em ambiente de teste e restringir no Épico 2.2 |
