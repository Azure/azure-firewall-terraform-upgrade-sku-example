# Azure Firewall Upgrade SKU Example - Terraform

## Description

Includes terraform examples on how to upgrade various SKUs of an Azure Firewall

## Features

1. Upgrading A Standard SKU Azure Firewall to Premium SKU Azure Firewall
## Requirements

1. Minimum version of v1.2 of terraform cli installed
1. Mimium version of 3.17.0 of the azurerm terraform provider **note this is included in the provider.tf file**

Test this by running the command

`terraform version`

A subscription created and the appropriate permissions to read, create, update, and potentially delete

## Walkthrough

### Standard to Premium

#### Explanation

This example creates two policies, one with a Standard SKU and one with a Premium SKU. They have the same Rule Collection Groups defined. It also creates a Standard SKU Azure Firewall. After following the instructions it will switch the Azure Firewall to using the Premium SKU and switch to use the Premium SKU policy at the same time.

#### Instructions

1. Run `cd standard_to_premium`
1. Edit necessary files to your liking (play with rules, etc)
1. Run `terraform plan -out create.tf`
1. Verify the plan is what you are expecting
1. Run `terraform apply create.tf`
1. Verify that you have a Standard SKU Azure Firewall in the subscription
1. Change the value of `"upgrade_firewall": false` to `"upgrade_firewall": true`
1. Run `terraform plan -out upgrade.tf`
1. Verify the plan is what you are expecting (changing the policy and changing the SKU without any deletion, only changing)
1. Run `terraform apply upgrade.tf`
1. After ~10 minutues or depending on the number of Rule Collection Groups, verify that the Azure Firewall created now has Premium SKU with the new policy

## Notes

1. Unfortunately, the azurerm provider does not currently support rule collection groups, which limits "copying" the rules of one rule collection group to a new one, since rule collection groups cannot share policies. Because terraform offers language features such as functions, variables, type, etc, this functionality can be mimiced using variables.
1. Please excuse my lack of filling out all the necessary properities. Within Azure Firewall Engineering we don't have a standard module we are using. This is a quick, best effort.

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
