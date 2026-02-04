variable "grafana_pass" {
  type        = string
  description = "The admin password for grafana"
  sensitive   = true
}

variable "postgres_pass" {
  type        = string
  description = "The admin password for the postgres instance"
  sensitive   = true
}

variable "storage_ip" {
  type        = string
  description = "IP Address for the NFS Server"
}
