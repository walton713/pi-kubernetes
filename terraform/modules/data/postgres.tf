resource "kubernetes_persistent_volume_v1" "postgres" {
  metadata {
    name = local.postgres.name

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
  wait_for_rollout = true

  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace_v1.data.metadata.0.name

    labels = {
      app = "postgres"
    }
  }

  spec {
    replicas               = 1
    revision_history_limit = 3

    selector {
      match_labels = {
        app = "postgres"
      }
    }

    template {
      metadata {
        labels = {
          app  = "postgres"
          name = "postgres"
        }
      }

      spec {
        container {
          image = "postgres:18"
          name  = "postgres"

          env {
            name  = "POSTGRES_PASSWORD"
            value = var.postgres_pass
          }

          port {
            container_port = 5432
            name           = "postgres"
          }

          volume_mount {
            mount_path = "/var/lib/postgresql"
            name       = "postgres-pvc"
          }
        }

        volume {
          name = "postgres-pvc"

          persistent_volume_claim {
            claim_name = "postgres"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "postgres" {
  wait_for_load_balancer = true

  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace_v1.data.metadata.0.name

    labels = {
      app = "postgres"
    }
  }

  spec {
    type = "NodePort"

    port {
      name        = "postgres"
      node_port   = 30432
      port        = 5432
      protocol    = "TCP"
      target_port = 5432
    }

    selector = {
      app = "postgres"
    }
  }
}
