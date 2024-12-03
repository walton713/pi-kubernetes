variable "nfs_server_ip" {
  description = "The IP address for the NFS server."
}

variable "mysql_root_password" {
  description = "The password for the mysql root user"
  sensitive   = true
}
