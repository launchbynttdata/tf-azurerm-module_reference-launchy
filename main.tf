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

data "azurerm_client_config" "client" {}

resource "random_password" "postgres_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

  for_each = var.resource_names_map

  region                  = join("", split("-", each.value.region))
  class_env               = var.class_env
  cloud_resource_type     = each.value.name
  instance_env            = var.instance_env
  instance_resource       = var.instance_resource
  maximum_length          = each.value.max_length
  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  use_azure_region_abbr   = true
}

module "resource_group" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm"
  version = "~> 1.0"

  name     = module.resource_names["rg"][var.resource_names_strategy]
  location = var.resource_names_map["rg"].region
  tags     = local.tags
}

module "app_service_plan" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/app_service_plan/azurerm"
  version = "~> 1.0"

  name                = module.resource_names["app_service_plan"][var.resource_names_strategy]
  resource_group_name = module.resource_group.name
  location            = var.resource_names_map["app_service_plan"].region

  os_type      = "Linux"
  sku_name     = "P1v2"
  worker_count = 1

  depends_on = [module.resource_group]

  tags = local.tags
}

module "web_app" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/web_app/azurerm"
  version = "~> 1.0"

  name                = module.resource_names["web_app"][var.resource_names_strategy]
  resource_group_name = module.resource_group.name
  location            = var.resource_names_map["web_app"].region

  service_plan_id                 = module.app_service_plan.id
  os_type                         = "Linux"
  public_network_access_enabled   = true
  key_vault_reference_identity_id = module.user_managed_identity.id

  identity = {
    type         = "UserAssigned"
    identity_ids = [module.user_managed_identity.id]
  }

  app_settings = local.app_settings
  site_config  = local.site_config

  depends_on = [module.resource_group, module.container_registry, module.user_managed_identity, module.app_service_plan]

  tags = local.tags
}

module "web_app_slot" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/web_app_slot/azurerm"
  version = "~> 1.0"

  name                = "staging"
  app_service_id      = module.web_app.web_app_id
  
  key_vault_reference_identity_id = module.user_managed_identity.id


  identity = {
    type         = "UserAssigned"
    identity_ids = [module.user_managed_identity.id]
  }

  app_settings = local.app_settings

  site_config = merge(local.site_config, {
    application_stack = {
      docker_image_name = "launchy:staging"
      docker_registry_url = "https://${module.container_registry.container_registry_login_server}"
    }
  })

  depends_on = [module.resource_group, module.container_registry, module.user_managed_identity, module.web_app]

  tags = local.tags
}

module "container_registry" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/container_registry/azurerm"
  version = "~> 2.0"

  container_registry_name = replace(module.resource_names["container_registry"][var.resource_names_strategy], "-", "")
  resource_group_name     = module.resource_group.name
  location                = var.resource_names_map["container_registry"].region

  sku           = "Basic"
  admin_enabled = true # Required for Azure App Service https://learn.microsoft.com/en-us/azure/app-service/quickstart-custom-container?tabs=dotnet&pivots=container-linux-vscode#create-a-container-registry

  depends_on = [module.resource_group]

  tags = local.tags
}

module "scope_map" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/container_registry_scope_map/azurerm"
  version = "~> 1.0"

  name                    = module.resource_names["scope_map"].minimal_random_suffix_without_any_separators
  resource_group_name     = module.resource_group.name
  container_registry_name = module.resource_names["container_registry"].minimal_random_suffix_without_any_separators
  actions                 = [
    "repositories/launchy/content/read",
    "repositories/launchy/content/write",
    "repositories/launchy/content/delete",
    "repositories/launchy/metadata/read",
    "repositories/launchy/metadata/write"
  ]

  depends_on = [module.resource_group, module.container_registry]
}

module "token" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/container_registry_token/azurerm"
  version = "~> 1.0"

  name                    = module.resource_names["token"][var.resource_names_strategy]
  resource_group_name     = module.resource_group.name
  container_registry_name = module.resource_names["container_registry"].minimal_random_suffix_without_any_separators
  scope_map_id            = module.scope_map.id

  depends_on = [module.scope_map]
}

module "token_password" {
  source = "git::https://github.com/launchbynttdata/tf-azurerm-module_primitive-container_registry_token_password.git?ref=feature!/init"

  container_registry_token_id = module.token.id

  depends_on = [module.token]
}

module "db_server" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/postgresql_server/azurerm"
  version = "~> 1.0"

  name                = module.resource_names["db_server"][var.resource_names_strategy]
  resource_group_name = module.resource_group.name
  location            = var.resource_names_map["db_server"].region

  sku_name                      = "B_Standard_B2s"
  storage_tier                  = "P4"
  storage_mb                    = 32768
  postgres_version              = "16" # 16 is the latest we can do through TF: https://github.com/hashicorp/terraform-provider-azurerm/issues/29998
  public_network_access_enabled = true # Seems to be this way in the JS subscription anyway
  zone                          = 1

  authentication = {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
    tenant_id                     = data.azurerm_client_config.client.tenant_id
  }

  administrator_login = local.postgres_admin_username
  administrator_password = random_password.postgres_password.result

  depends_on = [module.resource_group]

  tags = local.tags
}

module "database" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/postgresql_database/azurerm"
  version = "~> 1.0"

  name      = module.resource_names["database"][var.resource_names_strategy]
  server_id = module.db_server.id
  
  depends_on = [module.resource_group, module.db_server]
}

module "key_vault" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/key_vault/azurerm"
  version = "~> 2.0"

  key_vault_name = module.resource_names["key_vault"][var.resource_names_strategy]
  resource_group = {
    name     = module.resource_group.name
    location = var.resource_names_map["rg"].region
  }

  enable_rbac_authorization = true

  secrets = merge(local.user_configured_secrets, local.preconfigured_secrets)

  depends_on = [module.resource_group, module.token_password, module.db_server]
}

module "user_managed_identity" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/user_managed_identity/azurerm"
  version = "~> 1.3"

  user_assigned_identity_name = module.resource_names["user_managed_identity"][var.resource_names_strategy]
  resource_group_name         = module.resource_group.name
  location                    = var.resource_names_map["user_managed_identity"].region

  depends_on = [module.resource_group]

  tags = local.tags
}

module "managed_identity_keyvault_policy" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/role_assignment/azurerm"
  version = "~> 1.2"

  principal_id         = module.user_managed_identity.principal_id
  scope                = module.resource_group.id
  role_definition_name = "Key Vault Secrets User"
  principal_type       = "ServicePrincipal"

  depends_on = [module.resource_group]
}

module "managed_identity_acr_policy" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/role_assignment/azurerm"
  version = "~> 1.2"

  principal_id         = module.user_managed_identity.principal_id
  scope                = module.resource_group.id
  role_definition_name = "AcrPull"
  principal_type       = "ServicePrincipal"

  depends_on = [module.resource_group]
}

module "log_analytics_workspace" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/log_analytics_workspace/azurerm"
  version = "~> 1.0"

  name                = module.resource_names["log_workspace"][var.resource_names_strategy]
  location            = var.resource_names_map["log_workspace"].region
  resource_group_name = module.resource_group.name
  sku                 = "PerGB2018"

  tags = merge(var.tags, { resource_name = module.resource_names["log_workspace"].standard })

  depends_on = [module.resource_group]

}

module "application_insights" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/application_insights/azurerm"
  version = "~> 1.0"

  name                = module.resource_names["app_insights"][var.resource_names_strategy]
  resource_group_name = module.resource_group.name
  location            = var.resource_names_map["app_insights"].region
  workspace_id        = module.log_analytics_workspace.id

  depends_on = [module.resource_group, module.log_analytics_workspace]

  tags = merge(var.tags, { resource_name = module.resource_names["app_insights"].standard })
}