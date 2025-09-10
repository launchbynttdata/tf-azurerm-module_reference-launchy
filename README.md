# tf-azurerm-module_reference-launchy

## Overview

Reference Architecture for Launchy, a chatbot.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.117 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 2.0 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm | ~> 1.0 |
| <a name="module_app_service_plan"></a> [app\_service\_plan](#module\_app\_service\_plan) | terraform.registry.launch.nttdata.com/module_primitive/app_service_plan/azurerm | ~> 1.0 |
| <a name="module_web_app"></a> [web\_app](#module\_web\_app) | terraform.registry.launch.nttdata.com/module_primitive/web_app/azurerm | ~> 1.0 |
| <a name="module_web_app_slot"></a> [web\_app\_slot](#module\_web\_app\_slot) | terraform.registry.launch.nttdata.com/module_primitive/web_app_slot/azurerm | ~> 1.0 |
| <a name="module_container_registry"></a> [container\_registry](#module\_container\_registry) | terraform.registry.launch.nttdata.com/module_primitive/container_registry/azurerm | ~> 2.0 |
| <a name="module_scope_map"></a> [scope\_map](#module\_scope\_map) | terraform.registry.launch.nttdata.com/module_primitive/container_registry_scope_map/azurerm | ~> 1.0 |
| <a name="module_token"></a> [token](#module\_token) | terraform.registry.launch.nttdata.com/module_primitive/container_registry_token/azurerm | ~> 1.0 |
| <a name="module_token_password"></a> [token\_password](#module\_token\_password) | terraform.registry.launch.nttdata.com/module_primitive/container_registry_token_password/azurerm | ~> 1.0 |
| <a name="module_db_server"></a> [db\_server](#module\_db\_server) | terraform.registry.launch.nttdata.com/module_primitive/postgresql_server/azurerm | ~> 1.0 |
| <a name="module_database"></a> [database](#module\_database) | terraform.registry.launch.nttdata.com/module_primitive/postgresql_database/azurerm | ~> 1.0 |
| <a name="module_key_vault"></a> [key\_vault](#module\_key\_vault) | terraform.registry.launch.nttdata.com/module_primitive/key_vault/azurerm | ~> 2.0 |
| <a name="module_user_managed_identity"></a> [user\_managed\_identity](#module\_user\_managed\_identity) | terraform.registry.launch.nttdata.com/module_primitive/user_managed_identity/azurerm | ~> 1.3 |
| <a name="module_managed_identity_keyvault_policy"></a> [managed\_identity\_keyvault\_policy](#module\_managed\_identity\_keyvault\_policy) | terraform.registry.launch.nttdata.com/module_primitive/role_assignment/azurerm | ~> 1.2 |
| <a name="module_managed_identity_acr_policy"></a> [managed\_identity\_acr\_policy](#module\_managed\_identity\_acr\_policy) | terraform.registry.launch.nttdata.com/module_primitive/role_assignment/azurerm | ~> 1.2 |
| <a name="module_log_analytics_workspace"></a> [log\_analytics\_workspace](#module\_log\_analytics\_workspace) | terraform.registry.launch.nttdata.com/module_primitive/log_analytics_workspace/azurerm | ~> 1.0 |
| <a name="module_monitor_diagnostic_setting_prod"></a> [monitor\_diagnostic\_setting\_prod](#module\_monitor\_diagnostic\_setting\_prod) | terraform.registry.launch.nttdata.com/module_primitive/monitor_diagnostic_setting/azurerm | ~> 3.1 |
| <a name="module_monitor_diagnostic_setting_staging"></a> [monitor\_diagnostic\_setting\_staging](#module\_monitor\_diagnostic\_setting\_staging) | terraform.registry.launch.nttdata.com/module_primitive/monitor_diagnostic_setting/azurerm | ~> 3.1 |

## Resources

| Name | Type |
|------|------|
| [random_password.postgres_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [azurerm_client_config.client](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.existing_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the preexisting Resource Group to deploy resources into. If not provided, a new Resource Group will be created with a random suffix. | `string` | `null` | no |
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | A map of key to resource\_name that will be used by tf-launch-module\_library-resource\_name to generate resource names | <pre>map(object({<br>    name       = string<br>    max_length = optional(number, 60)<br>    region     = optional(string, "eastus2")<br>  }))</pre> | <pre>{<br>  "app_service_plan": {<br>    "name": "svcplan"<br>  },<br>  "container_registry": {<br>    "name": "acr"<br>  },<br>  "database": {<br>    "name": "launchydb"<br>  },<br>  "db_server": {<br>    "name": "db"<br>  },<br>  "diagnostic_settings_prod": {<br>    "name": "diagprod"<br>  },<br>  "diagnostic_settings_staging": {<br>    "name": "diagstaging"<br>  },<br>  "key_vault": {<br>    "max_length": 24,<br>    "name": "kv"<br>  },<br>  "log_workspace": {<br>    "max_length": 60,<br>    "name": "logs"<br>  },<br>  "rg": {<br>    "name": "rg"<br>  },<br>  "scope_map": {<br>    "name": "scopemap"<br>  },<br>  "token": {<br>    "name": "token"<br>  },<br>  "user_managed_identity": {<br>    "name": "umi"<br>  },<br>  "web_app": {<br>    "name": "webapp"<br>  },<br>  "web_app_staging": {<br>    "name": "webappstg"<br>  }<br>}</pre> | no |
| <a name="input_resource_names_strategy"></a> [resource\_names\_strategy](#input\_resource\_names\_strategy) | Strategy to use for generating resource names, taken from the outputs of the naming module, e.g. 'standard', 'minimal\_random\_suffix', 'dns\_compliant\_standard', etc. | `string` | `"minimal_random_suffix"` | no |
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | (Required) Name of the product family for which the resource is created.<br>    Example: org\_name, department\_name. | `string` | `"launch"` | no |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | (Required) Name of the product service for which the resource is created.<br>    For example, backend, frontend, middleware etc. | `string` | `"example"` | no |
| <a name="input_class_env"></a> [class\_env](#input\_class\_env) | (Required) Environment where resource is going to be deployed. For example: dev, qa, uat | `string` | `"sandbox"` | no |
| <a name="input_instance_env"></a> [instance\_env](#input\_instance\_env) | Number that represents the instance of the environment. | `number` | `0` | no |
| <a name="input_instance_resource"></a> [instance\_resource](#input\_instance\_resource) | Number that represents the instance of the resource. | `number` | `0` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. | `map(string)` | `{}` | no |
| <a name="input_system_tags"></a> [system\_tags](#input\_system\_tags) | Tags applied to your resources by the pipeline, if deployed with a Launch workflow. These take precedence over any user-defined tags with matching names if they are supplied. | `map(string)` | `{}` | no |
| <a name="input_secret_configurations"></a> [secret\_configurations](#input\_secret\_configurations) | Secret configurations to create for the application. Do not provide the<br>    secret values here, a placeholder value will be used and you will need<br>    to enter the secret into the Azure Portal or via CLI/PowerShell after<br>    deployment.<br><br>    Some secrets are preconfigured by this module, including:<br>      - DB\_HOST<br>      - DB\_USER<br>      - DB\_PASSWORD<br><br>    You may not specify preconfigured secrets in this list. Secret names<br>    provided here should match the desired environment variable name and<br>    capitalization. | `list(string)` | `[]` | no |
| <a name="input_configurations"></a> [configurations](#input\_configurations) | Non-secret configurations to create for the application. These will be stored as App Settings in the Web App. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acr_login_command"></a> [acr\_login\_command](#output\_acr\_login\_command) | The command to login to the Key Vault using the User Managed Identity |
| <a name="output_container_registry_name"></a> [container\_registry\_name](#output\_container\_registry\_name) | The name of the Container Registry |
| <a name="output_container_registry_username"></a> [container\_registry\_username](#output\_container\_registry\_username) | The username to access the Container Registry |
| <a name="output_container_registry_password"></a> [container\_registry\_password](#output\_container\_registry\_password) | The password to access the Container Registry |
<!-- END_TF_DOCS -->

## Update this Module from the Base template

This module utilizes a Copier template to generate files. To update the module with changes from the base template, create a branch as usual and run the following command:

```bash
make update
```

This will pull in the latest changes from the base template and update the module files accordingly. Conflicts between the template and your repository will be marked with merge conflict markers. Review the changes carefully before committing.

## Release Process

To release an updated version of this Terraform module, follow these steps:

1. Clone the repository locally and ensure that you can `make configure`.
2. Create a new branch for your changes. By default, we'll bump versions according to the [branch naming workflow](https://github.com/launchbynttdata/launch-workflows/blob/main/docs/reusable-pr-label-by-branch.md), so make sure you have your branch name prefixed correctly.
3. Make your changes to the Terraform code, tests, documentation, or other files as needed.
4. Test your changes locally with `make lint` and `make test` (or `make check` to perform both at the same time). Make sure you're logged into the cloud provider, as this will create and destroy your example resources in the course of running tests.
5. Push your changes to the remote repository and open a pull request against the `main` branch. Tests will run automatically, and you can review the results in the pull request.
6. Once your pull request passes all tests and has received the necessary approvals, merge it into the `main` branch. Upon merge to main, a Release will be created automatically with the next version determined based on your pull request.
