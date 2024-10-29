Documentação da Implementação de Centralização de Logs para a r3a.com no Google Cloud

Introdução

Este documento descreve a implementação da centralização de logs para a r3a.com no Google Cloud, especificamente para rotear logs dos projetos e folders no folder 'r3a-infrastructure' para buckets de log centralizados no projeto 'r3a-monitoring-svcs-hmg'. Esta configuração visa simplificar o gerenciamento de logs e otimizar o monitoramento da infraestrutura.

Detalhes da Implementação

Configuração do Projeto 'r3a-monitoring-svcs-hmg'

No projeto 'r3a-monitoring-svcs-hmg', foram configurados sinks de log em diferentes níveis para coletar logs dos projetos filhos e do folder 'r3a-infrastructure'. Segue uma descrição das principais configurações de Terraform adotadas:


    1. 1. **Locals**
Definição de variáveis locais para simplificar a referência dos IDs de projeto e bucket, nomes de sinks, service accounts, entre outras variáveis. Exemplos:
- `source_project_id`, `source_log_sink_name`, `target_project_id`
- Identidade de service account padrão: `cloud-logs@system.gserviceaccount.com`

    2. 2. **google_logging_project_sink 'logsink_error'**
Este recurso define o log sink para rotear logs de um projeto específico com filtro de gravidade de logs (≥ ERROR) para o bucket centralizado no projeto de destino.
- Configurado `unique_writer_identity = false` para uso da service account padrão.
- Filtro para logs com gravidade ≥ ERROR.

    3. 3. **google_logging_folder_sink 'folder-error-sink'**
Configuração de log sink para capturar logs no nível do folder 'r3a-infrastructure' e direcioná-los ao bucket centralizado. Inclui logs de subfolders e projetos filhos com filtro ≥ ERROR.
- Configuração de `include_children = true` para capturar logs de subpastas.

Configuração de Permissões IAM
Permissões IAM foram configuradas para garantir que a service account `cloud-logs@system.gserviceaccount.com` e as identidades de writer geradas tenham as permissões necessárias nos buckets de destino:
- **Funções**: `roles/logging.bucketWriter`, `roles/logging.logWriter`.
Exemplo de Código Terraform para Configuração de Sinks de Log
Segue o código de exemplo utilizado para configurar os sinks de log para centralização no projeto 'r3a-monitoring-svcs-hmg'. Este exemplo inclui a configuração de buckets e permissões:


locals {
  source_project_id                 = var.project_id
  source_project_name               = local.source_project_id
  source_log_sink_name              = "logsink-er-${local.source_project_name}-${var.default_region}"
  source_folder_log_sink_name       = "folder-logsink-er-${local.source_folder_id}"
  target_project_id                 = "r3a-monitoring-svcs-${var.env}"
  target_logstorage_bucket_name     = "log-bkt-er-${local.target_project_id}-global"
  sa_cloudlogs_email                = "cloud-logs@system.gserviceaccount.com"
}

resource "google_logging_project_sink" "logsink_error" {
  name = "${local.source_log_sink_name}"
  destination = "logging.googleapis.com/projects/${local.target_project_id}/locations/global/buckets/${local.target_logstorage_bucket_name}"
  filter = "severity >= ERROR"
  unique_writer_identity = false
}

resource "google_logging_folder_sink" "folder-error-sink" {
  name   = "${local.source_folder_log_sink_name}"
  folder = local.source_folder_id
  destination = "logging.googleapis.com/projects/${local.target_project_id}/locations/global/buckets/${local.target_logging_folder_bucket_name}"
  include_children = true
  filter = "severity >= ERROR"
}
    
Recomendações e Considerações para a Centralização de Logs

1. **Segurança e Permissões**: Configure corretamente as permissões IAM para todas as identidades de escrita envolvidas, garantindo o acesso necessário aos buckets centralizados de log.

2. **Validação de Logs**: Teste o fluxo de logs nos ambientes de teste antes de implementar em produção para validar a consistência dos dados e permissões.

3. **Configuração de Retenção**: Ajuste a retenção dos logs de acordo com as políticas de conformidade e requisitos do projeto, como feito com o recurso `google_logging_project_bucket_config`.


Documentação para Integração de Projetos ao Sistema Centralizado de Logs no Google Cloud

Introdução

Este documento fornece instruções detalhadas para configurar novos projetos para roteamento de logs ao bucket centralizado 'log-bkt-er-r3a-monitoring-svcs-hmg-global' no projeto 'r3a-monitoring-svcs-hmg'. Duas abordagens são descritas: utilização de logs por projeto e logs centralizados por folder no Google Cloud.

1. Configuração de Logs Centralizados por Projeto

Para adicionar um novo projeto ao bucket de logs centralizado, basta copiar os arquivos 'locals.tf' e 'logsink.tf' para a pasta Terraform do projeto a ser monitorado. Estes arquivos configuram um 'log sink' no nível do projeto e roteiam os logs para o bucket central 'log-bkt-er-r3a-monitoring-svcs-hmg-global'.
Este método permite um controle granular dos logs em cada projeto e é ideal para projetos que requerem uma política de retenção ou filtragem de logs personalizada.

Exemplo de Código Terraform: locals.tf

locals {
  source_project_id                 = var.project_id
  source_project_name               = local.source_project_id
  source_log_sink_name              = "logsink-er-${local.source_project_name}-${var.default_region}"
  target_project_id                 = "r3a-monitoring-svcs-${var.env}"
  target_logstorage_bucket_name     = "log-bkt-er-${local.target_project_id}-global"
  sa_cloudlogs_email                = "cloud-logs@system.gserviceaccount.com"
}
    
Exemplo de Código Terraform: logsink.tf

resource "google_logging_project_sink" "logsink_error" {
  name = "${local.source_log_sink_name}"
  destination = "logging.googleapis.com/projects/${local.target_project_id}/locations/global/buckets/${local.target_logstorage_bucket_name}"
  filter = "severity >= ERROR"
  unique_writer_identity = true
}

resource "google_project_iam_member" "custom-sa-logbucket-binding" {
  for_each = var.writer_identity_roles
  project = local.target_project_id
  role = each.value
  member  = "serviceAccount:${local.sa_cloudlogs_email}"
}
    
2. Configuração de Logs Centralizados por Folder

O roteamento dos logs de todos os projetos abaixo do folder 'r3a-infrastructure' já está configurado para o bucket 'folder-bkt-er-r3a-monitoring-svcs-hmg-global'. Com isso, não é necessário configurar individualmente cada projeto do folder, simplificando a implementação.

No entanto, esta abordagem apresenta alguns pontos a serem analisados:

- **Consumo de armazenamento**: O bucket 'folder-bkt-er-r3a-monitoring-svcs-hmg-global' tem mostrado um aumento significativo de consumo, acumulando rapidamente um grande volume de dados.

- **Complexidade nos Filtros de Logs**: A configuração de filtros pode ser menos granular quando aplicada em nível de folder, dificultando o controle detalhado de logs específicos.

Considerações e Recomendação de Abordagem

1. **Abordagem por Projeto**: Ideal para casos onde a granularidade e controle dos logs por projeto é necessária. Permite personalizar políticas de retenção e filtragem.

2. **Abordagem por Folder**: Simplifica a configuração para múltiplos projetos. Recomendada quando o volume de logs é controlável e o nível de detalhes não é uma prioridade. Atenção ao consumo do bucket e necessidade de ajustes periódicos.
