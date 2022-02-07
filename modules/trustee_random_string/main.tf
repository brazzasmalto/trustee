# Generate a random storage name
resource "random_string" "tf-name" {
  length = 8
  upper = false
  number = true
  lower = true
  special = false
}

resource "random_string" "random" {
  length           = 16
  special          = true
  override_special = "/@£$"
}

resource "random_string" "str" {
  length  = 6
  special = false
  upper   = false
  keepers = {
    domain_name_label = var.azure_bastion_service_name
  }
}