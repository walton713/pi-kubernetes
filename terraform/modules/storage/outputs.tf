output "storage_ip" {
  value = data.kubernetes_service_v1.nfs.spec.0.cluster_ip
}
