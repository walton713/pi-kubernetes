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

  prometheus = {
    name       = "prometheus"
    repository = "https://prometheus-community.github.io/helm-charts"

    exporters = {
      postgres = {
        name   = "prometheus-postgres-exporter"
        port   = "9187"
        schema = "http"
        scrape = "true"

        datasource = {
          database = "postgres"
          host     = "postgres.data.svc.cluster.local"
          port     = "5432"
          user     = "postgres"
        }
      }

      redis = {
        address = "redis://redis.data.svc.cluster.local:6379"
        name    = "prometheus-redis-exporter"
        port    = "9121"
        schema  = "http"
        scrape  = "true"
      }
    }

    ingress = {
      name   = "nginx-ingress-microk8s-controller"
      path   = "/metrics"
      port   = "10254"
      schema = "http"
      scrape = "true"
    }

    operator = {
      chart = "kube-prometheus-stack"
      name  = "prometheus-operator"
    }

    persistence = {
      access_modes   = ["ReadWriteOnce"]
      capacity       = "20Gi"
      nfs_path       = "/prometheus"
      reclaim_policy = "Retain"
      storage_class  = "slow"
      volume_mode    = "Filesystem"

      labels = {
        directory = "prometheus"
      }
    }

    release = {
      host            = "prometheus.local"
      ingress_class   = "nginx"
      scrape_interval = "15s"
    }
  }
}
