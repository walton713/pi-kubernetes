resource "kubernetes_namespace_v1" "data" {
  metadata {
    name = "data"
  }
}

resource "kubernetes_persistent_volume_v1" "postgres" {
  metadata {
    name = "postgres"

    labels = {
      directory = "postgres"
    }
  }

  spec {
    access_modes                     = ["ReadWriteMany"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "fast"
    volume_mode                      = "Filesystem"

    capacity = {
      storage = "400Gi"
    }

    persistent_volume_source {
      nfs {
        path   = "/postgres"
        server = var.storage_ip
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "postgres" {
  wait_until_bound = true

  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace_v1.data.metadata.0.name
  }

  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "fast"

    resources {
      requests = {
        storage = "400Gi"
      }
    }

    selector {
      match_labels = {
        directory = "postgres"
      }
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
