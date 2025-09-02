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

output "acr_login_command" {
  description = "The command to login to the Key Vault using the User Managed Identity"
  value       = "az acr login -n ${replace(module.resource_names["container_registry"][var.resource_names_strategy], "-", "")} -u ${module.resource_names["token"][var.resource_names_strategy]} -p '${module.token_password.password1}'"
  sensitive   = true
}

output "container_registry_name" {
  description = "The name of the Container Registry"
  value       = replace(module.resource_names["container_registry"][var.resource_names_strategy], "-", "")
}

output "container_registry_username" {
  description = "The username to access the Container Registry"
  value       = module.resource_names["token"][var.resource_names_strategy]
}

output "container_registry_password" {
  description = "The password to access the Container Registry"
  value       = module.token_password.password1
  sensitive   = true
}