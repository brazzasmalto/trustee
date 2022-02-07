# Trustee Resource Group Modules

### Terraform Module to create Resource Group in Microsoft Azure
#### Tools Used
- Terraform: Version 0.14.09
- Azurerm provider: Version v2.83.0

#### Parameters to pass
| Parameters | Need | Description
| ------ | ------ | ------ |
source|(Required)|source of this module
name|(Required)|name of the resource group
location|(Required)|location where this resource has to be created
tags|(Optional)|tag a team


#### Usage:
```sh
provider "azurerm" {
  version = "=2.83.0"
  features {}
}

module "trustee_resource_group" {
  source   = "modules/trustee_resource_group"
  name     = "rg-trustee-application-001"
  location = "westeurope"
  tags = {
      ProjectName  = "trustee-transformation"
      Env          = "dev"
      Owner        = "FT Trustee"
    }
}
```

#### Terraform Execution:
###### To initialize Terraform:
```sh
terraform init
```

###### To execute Terraform Plan:
```sh
terraform plan -out trustee.tfplan
```

###### To apply Terraform changes:
```sh
terraform apply "trustee.tfplan"
```

###### To destroy module:
```sh
terraform destroy -target module.trustee_resource_group
```