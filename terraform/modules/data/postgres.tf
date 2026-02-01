resource "kubernetes_secret_v1" "postgres" {
  type = "Opaque"

  metadata {
    name      = "${local.postgres.name}-secret"
    namespace = local.namespace
  }

  data = {
    postgres_password = var.postgres_pass
  }
}

resource "kubernetes_persistent_volume_v1" "postgres" {
  metadata {
    name   = local.postgres.name
    labels = local.postgres.persistence.labels
  }

  spec {
    access_modes                     = local.postgres.persistence.access_modes
    persistent_volume_reclaim_policy = local.postgres.persistence.reclaim_policy
    storage_class_name               = local.postgres.persistence.storage_class
    volume_mode                      = local.postgres.persistence.volume_mode

    capacity = {
      storage = local.postgres.persistence.capacity
    }

    persistent_volume_source {
      nfs {
        path   = local.postgres.persistence.nfs_path
        server = var.storage_ip
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "postgres" {
  depends_on       = [kubernetes_namespace_v1.data]
  wait_until_bound = true

  metadata {
    name      = local.postgres.name
    namespace = local.namespace
  }

  spec {
    access_modes       = local.postgres.persistence.access_modes
    storage_class_name = local.postgres.persistence.storage_class

    resources {
      requests = {
        storage = local.postgres.persistence.capacity
      }
    }

    selector {
      match_labels = local.postgres.persistence.labels
    }
  }
}

resource "kubernetes_deployment_v1" "postgres" {
  depends_on       = [kubernetes_namespace_v1.data]
  wait_for_rollout = true

  metadata {
    name      = local.postgres.name
    namespace = local.namespace
    labels    = local.postgres.deployment.labels
  }

  spec {
    replicas               = local.postgres.deployment.replicas
    revision_history_limit = local.postgres.deployment.history

    selector {
      match_labels = local.postgres.deployment.labels
    }

    template {
      metadata {
        labels = local.postgres.deployment.labels
      }

      spec {
        container {
          image = local.postgres.deployment.image
          name  = local.postgres.name

          env {
            name = "POSTGRES_PASSWORD"

            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.postgres.metadata.0.name
                key  = "postgres_password"
              }
            }
          }

          port {
            container_port = local.postgres.deployment.port.port
            name           = local.postgres.deployment.port.name
          }

          volume_mount {
            mount_path = local.postgres.deployment.volume.mount_path
            name       = local.postgres.deployment.volume.name
          }
        }

        volume {
          name = local.postgres.deployment.volume.name

          persistent_volume_claim {
            claim_name = local.postgres.name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "postgres" {
  depends_on = [kubernetes_namespace_v1.data]
  metadata {
    name      = local.postgres.name
    namespace = local.namespace
    labels    = local.postgres.deployment.labels
  }

  spec {
    type = local.postgres.deployment.service_type

    port {
      name        = local.postgres.deployment.port.name
      node_port   = local.postgres.deployment.port.node_port
      port        = local.postgres.deployment.port.port
      protocol    = local.postgres.deployment.port.protocol
      target_port = local.postgres.deployment.port.port
    }

    selector = local.postgres.deployment.labels
  }
}
