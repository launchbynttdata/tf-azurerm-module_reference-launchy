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

variable "resource_group_name" {
  description = "The name of the preexisting Resource Group to deploy resources into. If not provided, a new Resource Group will be created with a random suffix."
  type        = string
  nullable    = true
  default     = null
}

variable "resource_names_map" {
  description = "A map of key to resource_name that will be used by tf-launch-module_library-resource_name to generate resource names"
  type = map(object({
    name       = string
    max_length = optional(number, 60)
    region     = optional(string, "eastus2")
  }))

  default = {
    rg = {
      name = "rg"
    }
    app_service_plan = {
      name = "svcplan"
    }
    web_app = {
      name = "webapp"
    }
    web_app_staging = {
      name = "webappstg"
    }
    container_registry = {
      name = "acr"
    }
    db_server = {
      name = "db"
    }
    database = {
      name = "launchydb"
    }
    user_managed_identity = {
      name = "umi"
    }
    key_vault = {
      name       = "kv"
      max_length = 24
    }
    token = {
      name = "token"
    }
    scope_map = {
      name = "scopemap"
    }
    app_insights = {
      name       = "appins"
      max_length = 60
    }
    log_workspace = {
      name       = "logs"
      max_length = 60
    },
    diagnostic_settings_prod = {
      name = "diagprod"
    }
    diagnostic_settings_staging = {
      name = "diagstaging"
    }
  }
}

variable "resource_names_strategy" {
  type        = string
  description = "Strategy to use for generating resource names, taken from the outputs of the naming module, e.g. 'standard', 'minimal_random_suffix', 'dns_compliant_standard', etc."
  nullable    = false
  default     = "minimal_random_suffix"
}

variable "logical_product_family" {
  type        = string
  description = <<EOF
    (Required) Name of the product family for which the resource is created.
    Example: org_name, department_name.
  EOF
  nullable    = false
  default     = "launch"

  validation {
    condition     = can(regex("^[A-Za-z0-9_]+$", var.logical_product_family))
    error_message = "logical_product_family may only contain letters, numbers, and underscores"
  }
}

variable "logical_product_service" {
  type        = string
  description = <<EOF
    (Required) Name of the product service for which the resource is created.
    For example, backend, frontend, middleware etc.
  EOF
  nullable    = false
  default     = "example"

  validation {
    condition     = can(regex("^[A-Za-z0-9_]+$", var.logical_product_service))
    error_message = "logical_product_service may only contain letters, numbers, and underscores"
  }
}

variable "class_env" {
  type        = string
  description = "(Required) Environment where resource is going to be deployed. For example: dev, qa, uat"
  nullable    = false
  default     = "sandbox"

  validation {
    condition     = can(regex("^[A-Za-z0-9_]+$", var.class_env))
    error_message = "class_env may only contain letters, numbers, and underscores"
  }
}

variable "instance_env" {
  type        = number
  description = "Number that represents the instance of the environment."
  nullable    = false
  default     = 0

  validation {
    condition     = var.instance_env >= 0 && var.instance_env <= 999
    error_message = "instance_env must be between 0 and 999, inclusive."
  }
}

variable "instance_resource" {
  type        = number
  description = "Number that represents the instance of the resource."
  nullable    = false
  default     = 0

  validation {
    condition     = var.instance_resource >= 0 && var.instance_resource <= 100
    error_message = "instance_resource must be between 0 and 100, inclusive."
  }
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  nullable    = true
  default     = {}
}

variable "system_tags" {
  description = "Tags applied to your resources by the pipeline, if deployed with a Launch workflow. These take precedence over any user-defined tags with matching names if they are supplied."
  type        = map(string)
  nullable    = true
  default     = {}
}

variable "secret_configurations" {
  description = <<EOF
    Secret configurations to create for the application. Do not provide the
    secret values here, a placeholder value will be used and you will need
    to enter the secret into the Azure Portal or via CLI/PowerShell after
    deployment.

    Some secrets are preconfigured by this module, including:
      - DB_HOST
      - DB_USER
      - DB_PASSWORD

    You may not specify preconfigured secrets in this list. Secret names
    provided here should match the desired environment variable name and
    capitalization.
  EOF
  type        = list(string)
  nullable    = true
  default     = []

  validation {
    condition     = alltrue([for s in var.secret_configurations : can(regex("^[A-Za-z0-9_]+$", s))])
    error_message = "Each secret name in secret_configurations may only contain letters, numbers, and underscores."
  }

  validation {
    condition     = alltrue([for s in var.secret_configurations : !contains(["DB_HOST", "DB_USER", "DB_PASSWORD"], s)])
    error_message = "You may not specify preconfigured secrets (DB_HOST, DB_USER, DB_PASSWORD) in secret_configurations."
  }
}

variable "configurations" {
  description = "Non-secret configurations to create for the application. These will be stored as App Settings in the Web App."
  type        = map(string)
  nullable    = true
  default     = {}
}
