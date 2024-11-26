output "storage_ip" {
  value = kubernetes_service_v1.nfs-server.spec.0.cluster_ip
}