variable "name" {
  type        = string
  description = "Who to greet."
}

output "greeting" {
  value = "Hello, ${var.name}!"
}
