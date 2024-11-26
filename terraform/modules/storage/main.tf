resource "kubernetes_namespace_v1" "storage" {
  metadata {
    name = "storage"

    labels = {
      app = "storage"
    }
  }
}

resource "kubernetes_persistent_volume_v1" "local-pv" {
  metadata {
    name = "local-pv"
  }

  spec {
    access_modes                     = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "local-storage"


    capacity = {
      storage = "400Gi"
    }

    persistent_volume_source {
      local {
        path = "/nfs"
      }
    }

    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "hdd"
            operator = "In"
            values   = ["enabled"]
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "local-pvc" {
  metadata {
    name      = "local-pvc"
    namespace = "storage"
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "local-storage"

    resources {
      requests = {
        storage = "400Gi"
      }
    }
  }
}

resource "kubernetes_deployment_v1" "nfs-server" {
  metadata {
    name      = "nfs-server"
    namespace = "storage"

    labels = {
      app = "nfs-server"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nfs-server"
      }
    }

    template {
      metadata {
        labels = {
          app  = "nfs-server"
          name = "nfs-server"
        }
      }

      spec {
        container {
          name  = "nfs-server"
          image = "itsthenetwork/nfs-server-alpine:11-arm"

          env {
            name  = "SHARED_DIRECTORY"
            value = "/exports"
          }

          port {
            name           = "nfs"
            container_port = 2049
          }

          port {
            name           = "mountd"
            container_port = 20048
          }

          port {
            name           = "rpcbind"
            container_port = 111
          }

          security_context {
            privileged = true
          }

          volume_mount {
            name       = "mypvc"
            mount_path = "/exports"
          }
        }

        volume {
          name = "mypvc"
          persistent_volume_claim {
            claim_name = "local-pvc"
          }
        }

        node_selector = {
          hdd = "enabled"
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "nfs-server" {
  metadata {
    name      = "nfs-server"
    namespace = "storage"
  }

  spec {
    type = "ClusterIP"

    port {
      name = "nfs"
      port = 2049
    }

    port {
      name = "mountd"
      port = 20048
    }

    port {
      name = "rpcbind"
      port = 111
    }

    selector = {
      app = "nfs-server"
    }
  }
}
