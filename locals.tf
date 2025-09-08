// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

locals {
  default_tags = {
    provisioner = "Terraform"
  }

  resource_group_name     = var.resource_group_name != null ? var.resource_group_name : module.resource_group[0].name
  resource_group_id       = var.resource_group_name != null ? data.azurerm_resource_group.existing_resource_group[0].id : module.resource_group[0].id
  resource_group_location = var.resource_group_name != null ? data.azurerm_resource_group.existing_resource_group[0].location : var.resource_names_map["rg"].region

  postgres_admin_username = "postgres"

  default_secrets = [
    "ACR_TOKEN_USER",
    "ACR_TOKEN_PASSWORD_1",
    "ACR_TOKEN_PASSWORD_2",
    "DB_HOST",
    "DB_USER",
    "DB_PASSWORD",
    "APP_INSIGHTS_INSTRUMENTATION_KEY",
    "APP_INSIGHTS_CONNECTION_STRING",
  ]
  preconfigured_secrets = {
    "ACR-TOKEN-USER" : module.resource_names["token"][var.resource_names_strategy]
    "ACR-TOKEN-PASSWORD-1" : module.token_password.password1
    "ACR-TOKEN-PASSWORD-2" : module.token_password.password2
    "APP-INSIGHTS-INSTRUMENTATION-KEY" : module.application_insights.instrumentation_key
    "APP-INSIGHTS-CONNECTION-STRING" : module.application_insights.connection_string
    "DB-USER" : local.postgres_admin_username
    "DB-PASSWORD" : random_password.postgres_password.result
    "DB-HOST" : module.db_server.fqdn
  }
  user_configured_secrets = { for s in var.secret_configurations : replace(s, "_", "-") => "UPDATE_ME" }

  app_settings = merge(
    var.configurations,
    { "DB_NAME" : module.resource_names["database"][var.resource_names_strategy] },
  { for s in concat(local.default_secrets, var.secret_configurations) : s => "@Microsoft.KeyVault(SecretUri=${module.key_vault.vault_uri}secrets/${replace(s, "_", "-")})" })

  site_config = {
    application_stack = {
      docker_image_name   = "launchy-api:production"
      docker_registry_url = "https://${module.container_registry.container_registry_login_server}"
    }
    http2_enabled                                 = true
    container_registry_managed_identity_client_id = module.user_managed_identity.client_id
    container_registry_use_managed_identity       = true
  }

  tags = merge(local.default_tags, var.tags, var.system_tags)
}
