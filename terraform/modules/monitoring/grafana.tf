resource "kubernetes_persistent_volume_v1" "grafana" {
  metadata {
    name   = local.grafana.name
    labels = local.grafana.persistence.labels
  }

  spec {
    access_modes                     = local.grafana.persistence.access_modes
    persistent_volume_reclaim_policy = local.grafana.persistence.reclaim_policy
    storage_class_name               = local.grafana.persistence.storage_class
    volume_mode                      = local.grafana.persistence.volume_mode

    capacity = {
      storage = local.grafana.persistence.capacity
    }

    persistent_volume_source {
      nfs {
        path   = local.grafana.persistence.nfs_path
        server = var.storage_ip
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "grafana" {
  depends_on       = [kubernetes_namespace_v1.monitoring, kubernetes_persistent_volume_v1.grafana]
  wait_until_bound = true

  metadata {
    name      = local.grafana.name
    namespace = local.namespace
  }

  spec {
    access_modes       = local.grafana.persistence.access_modes
    storage_class_name = local.grafana.persistence.storage_class

    resources {
      requests = {
        storage = local.grafana.persistence.capacity
      }
    }

    selector {
      match_labels = local.grafana.persistence.labels
    }
  }
}

resource "helm_release" "grafana" {
  depends_on = [kubernetes_namespace_v1.monitoring, kubernetes_persistent_volume_claim_v1.grafana]
  name       = local.grafana.name
  repository = local.grafana.release.repository
  chart      = local.grafana.name
  namespace  = local.namespace

  values = [
    yamlencode({
      initChownData = {
        enabled = false
      }
      rbac = {
        create = false
      }
      serviceAccount = {
        create = false
      }
      ingress = {
        enabled = true
        annotations = {
          "kubernetes.io/ingress-class" = local.grafana.release.ingress_class
        }
        hosts = [
          local.grafana.release.host
        ]
      }
      persistence = {
        enabled       = true
        existingClaim = kubernetes_persistent_volume_claim_v1.grafana.metadata.0.name
      }
      adminPassword     = var.grafana_pass
      namespaceOverride = local.namespace
    })
  ]
}
