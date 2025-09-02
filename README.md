# tf-azurerm-module_reference-launchy

## Overview

Reference Architecture for Launchy, a chatbot.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.117 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_storage_account.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Name of the Azure Storage Account to create. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Azure Resource Group for the storage account. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Location for the storage account. | `string` | `"eastus2"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the storage account. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | n/a |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | n/a |
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
