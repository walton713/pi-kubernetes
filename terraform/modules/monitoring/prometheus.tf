resource "kubernetes_annotations" "nginx" {
  api_version = "apps/v1"
  kind        = "DaemonSet"

  metadata {
    name      = local.prometheus.ingress.name
    namespace = "ingress"
  }

  template_annotations = {
    "prometheus.io/schema" = local.prometheus.ingress.schema
    "prometheus.io/scrape" = local.prometheus.ingress.scrape
    "prometheus.io/path"   = local.prometheus.ingress.path
    "prometheus.io/port"   = local.prometheus.ingress.port
  }
}

resource "kubernetes_persistent_volume_v1" "prometheus" {
  metadata {
    name   = local.prometheus.name
    labels = local.prometheus.persistence.labels
  }

  spec {
    access_modes                     = local.prometheus.persistence.access_modes
    persistent_volume_reclaim_policy = local.prometheus.persistence.reclaim_policy
    storage_class_name               = local.prometheus.persistence.storage_class
    volume_mode                      = local.prometheus.persistence.volume_mode

    capacity = {
      storage = local.prometheus.persistence.capacity
    }

    persistent_volume_source {
      nfs {
        path   = local.prometheus.persistence.nfs_path
        server = var.storage_ip
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "prometheus" {
  depends_on       = [kubernetes_namespace_v1.monitoring, kubernetes_persistent_volume_v1.prometheus]
  wait_until_bound = true

  metadata {
    name      = local.prometheus.name
    namespace = local.namespace
  }

  spec {
    access_modes       = local.prometheus.persistence.access_modes
    storage_class_name = local.prometheus.persistence.storage_class

    resources {
      requests = {
        storage = local.prometheus.persistence.capacity
      }
    }

    selector {
      match_labels = local.prometheus.persistence.labels
    }
  }
}

resource "helm_release" "prometheus" {
  depends_on = [kubernetes_namespace_v1.monitoring, kubernetes_persistent_volume_claim_v1.prometheus]
  name       = local.prometheus.name
  repository = local.prometheus.repository
  chart      = local.prometheus.name
  namespace  = local.namespace

  values = [
    yamlencode({
      rbac = {
        create = false
      }
      serviceAccounts = {
        server = {
          create = false
        }
      }
      server = {
        global = {
          scrape_interval = local.prometheus.release.scrape_interval
        }
        ingress = {
          enabled = true
          annotations = {
            "kubernetes.io/ingress-class" = local.prometheus.release.ingress_class
          }
          hosts = [
            local.prometheus.release.host
          ]
        }
        persistentVolume = {
          enabled = false
        }
      }
      alertmanager = {
        enabled = false
      }
    })
  ]
}

resource "helm_release" "prometheus-operator" {
  depends_on = [kubernetes_namespace_v1.monitoring]
  name       = local.prometheus.operator.name
  repository = local.prometheus.repository
  chart      = local.prometheus.operator.chart
  namespace  = local.namespace

  values = [
    yamlencode({
      kubeStateMetrics = {
        enabled = false
      }
      nodeExporter = {
        enabled = false
      }
      grafana = {
        enabled = false
      }
    })
  ]
}

resource "helm_release" "prometheus-postgres-exporter" {
  depends_on = [kubernetes_namespace_v1.monitoring]
  name       = local.prometheus.exporters.postgres.name
  repository = local.prometheus.repository
  chart      = local.prometheus.exporters.postgres.name
  namespace  = local.namespace

  values = [
    yamlencode({
      rbac = {
        create = false
      }
      serviceAccount = {
        create = false
      }
      annotations = {
        "prometheus.io/port"   = local.prometheus.exporters.postgres.port
        "prometheus.io/schema" = local.prometheus.exporters.postgres.schema
        "prometheus.io/scrape" = local.prometheus.exporters.postgres.scrape
      }
      namespaceOverride = local.namespace
      config = {
        datasource = {
          database = local.prometheus.exporters.postgres.datasource.database
          host     = local.prometheus.exporters.postgres.datasource.host
          password = var.postgres_pass
          port     = local.prometheus.exporters.postgres.datasource.port
          user     = local.prometheus.exporters.postgres.datasource.user
        }
      }
    })
  ]
}

resource "helm_release" "prometheus-redis-exporter" {
  depends_on = [kubernetes_namespace_v1.monitoring]
  name       = local.prometheus.exporters.redis.name
  repository = local.prometheus.repository
  chart      = local.prometheus.exporters.redis.name
  namespace  = local.namespace

  values = [
    yamlencode({
      rbac = {
        create = false
      }
      serviceAccount = {
        create = false
      }
      redisAddress      = local.prometheus.exporters.redis.address
      namespaceOverride = local.namespace
      annotations = {
        "prometheus.io/port"   = local.prometheus.exporters.redis.port
        "prometheus.io/schema" = local.prometheus.exporters.redis.schema
        "prometheus.io/scrape" = local.prometheus.exporters.redis.scrape
      }
    })
  ]
}
