resource "random_id" "random_id" {
  byte_length = 8
}

resource "random_id" "random_id_counter" {
  byte_length = 3
}

resource "random_id" "unique_name" {
  count = var.unique_name
  byte_length = 8
}