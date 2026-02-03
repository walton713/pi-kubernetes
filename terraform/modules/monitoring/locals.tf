locals {
  namespace = "monitoring"

  grafana = {
    name = "grafana"

    persistence = {
      access_modes   = ["ReadWriteOnce"]
      capacity       = "20Gi"
      nfs_path       = "/grafana"
      reclaim_policy = "Retain"
      storage_class  = "slow"
      volume_mode    = "Filesystem"

      labels = {
        directory = "grafana"
      }
    }

    release = {
      host          = "grafana.local"
      ingress_class = "nginx"
      repository    = "https://grafana.github.io/helm-charts"
    }
  }
}
