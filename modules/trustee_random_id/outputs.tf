output "random_id" {
  description = "Specifies the resource id of the random_id with byte_length = 8"
  value = random_id.random_id.id
}

output "random_id_counter" {
  description = "Specifies the resource id of the random_id with byte_length = 3"
  value = random_id.random_id_counter.id
}

output "random_unique_id"{
  value = random_id.unique_name.*.hex
}
