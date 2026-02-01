resource "kubernetes_persistent_volume_v1" "redis" {
  metadata {
    name   = local.redis.name
    labels = local.redis.persistence.labels
  }

  spec {
    access_modes                     = local.redis.persistence.access_modes
    persistent_volume_reclaim_policy = local.redis.persistence.reclaim_policy
    storage_class_name               = local.redis.persistence.storage_class
    volume_mode                      = local.redis.persistence.volume_mode

    capacity = {
      storage = local.redis.persistence.capacity
    }

    persistent_volume_source {
      nfs {
        path   = local.redis.persistence.nfs_path
        server = var.storage_ip
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "redis" {
  depends_on       = [kubernetes_namespace_v1.data, kubernetes_persistent_volume_v1.redis]
  wait_until_bound = true

  metadata {
    name      = local.redis.name
    namespace = local.namespace
  }

  spec {
    access_modes       = local.redis.persistence.access_modes
    storage_class_name = local.redis.persistence.storage_class

    resources {
      requests = {
        storage = local.redis.persistence.capacity
      }
    }

    selector {
      match_labels = local.redis.persistence.labels
    }
  }
}

resource "kubernetes_deployment_v1" "redis" {
  depends_on       = [kubernetes_namespace_v1.data, kubernetes_persistent_volume_claim_v1.redis]
  wait_for_rollout = true

  metadata {
    name      = local.redis.name
    namespace = local.namespace
    labels    = local.redis.deployment.labels
  }

  spec {
    replicas               = local.redis.deployment.replicas
    revision_history_limit = local.redis.deployment.history

    selector {
      match_labels = local.redis.deployment.labels
    }

    template {
      metadata {
        labels = local.redis.deployment.labels
      }

      spec {
        container {
          image = local.redis.deployment.image
          name  = local.redis.name

          port {
            container_port = local.redis.deployment.port.port
            name           = local.redis.deployment.port.name
          }

          volume_mount {
            mount_path = local.redis.deployment.volume.mount_path
            name       = local.redis.deployment.volume.name
          }
        }

        volume {
          name = local.redis.deployment.volume.name

          persistent_volume_claim {
            claim_name = local.redis.name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "redis" {
  depends_on = [kubernetes_namespace_v1.data, kubernetes_deployment_v1.redis]
  metadata {
    name      = local.redis.name
    namespace = local.namespace
    labels    = local.redis.deployment.labels
  }

  spec {
    type = local.redis.deployment.service_type

    port {
      name        = local.redis.deployment.port.name
      node_port   = local.redis.deployment.port.node_port
      port        = local.redis.deployment.port.port
      protocol    = local.redis.deployment.port.protocol
      target_port = local.redis.deployment.port.port
    }

    selector = local.redis.deployment.labels
  }
}
