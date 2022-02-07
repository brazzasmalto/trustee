output "random_password_with_keeper" {
  value = module.trustee_random_password.this_password
  sensitive = true
}

output "random_str" {
  value     = module.trustee_random_string.resource_code
}