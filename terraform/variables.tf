variable "postgres_pass" {
  type        = string
  description = "The admin password for the postgres instance"
  sensitive   = true
}