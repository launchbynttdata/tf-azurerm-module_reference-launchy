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

module "launchy" {
  source = "../.."

  logical_product_family  = "academy"
  logical_product_service = "launchy"
  resource_group_name     = "academy-launchy-rg-test"

  configurations = {
    "LOG_LEVEL" : "INFO"
  }

  secret_configurations = [
    "AZURE_OPENAI_API_KEY",
    "FIRECRAWL_API_KEY"
  ]

}
