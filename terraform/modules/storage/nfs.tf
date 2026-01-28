resource "kubernetes_labels" "master_node" {
  api_version = "v1"
  kind        = "Node"

  metadata {
    name = "master1"
  }

  labels = {
    hdd = "enabled"
  }
}

resource "kubernetes_namespace_v1" "storage" {
  metadata {
    name = "storage"
  }
}

resource "kubernetes_persistent_volume_v1" "nfs" {
  metadata {
    name = "nfs"

    labels = {
      directory = "data"
    }
  }

  spec {
    access_modes                     = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "local-storage"

    capacity = {
      storage = "800Gi"
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

    persistent_volume_source {
      local {
        path = "/mnt/data"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "nfs" {
  wait_until_bound = true

  metadata {
    name      = "nfs"
    namespace = "storage"
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "local-storage"

    resources {
      requests = {
        storage = "800Gi"
      }
    }

    selector {
      match_labels = {
        directory = "data"
      }
    }
  }
}

resource "kubernetes_deployment_v1" "nfs" {
  wait_for_rollout = true

  metadata {
    name      = "nfs-server"
    namespace = "storage"

    labels = {
      app = "nfs-server"
    }
  }

  spec {
    replicas               = "1"
    revision_history_limit = 3

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
          image = "itsthenetwork/nfs-server-alpine:11-arm"
          name  = "nfs-server"

          env {
            name  = "SHARED_DIRECTORY"
            value = "/exports"
          }

          port {
            container_port = 2049
            name           = "nfs"
          }

          port {
            container_port = 20048
            name           = "mountd"
          }

          port {
            container_port = 111
            name           = "rpcbind"
          }

          security_context {
            privileged = true
          }

          volume_mount {
            mount_path = "/exports"
            name       = "nfs-pvc"
          }
        }

        node_selector = {
          hdd = "enabled"
        }

        volume {
          name = "nfs-pvc"

          persistent_volume_claim {
            claim_name = "nfs"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "nfs" {
  wait_for_load_balancer = true

  metadata {
    name      = "nfs-server"
    namespace = "storage"

    labels = {
      app = "nfs-server"
    }
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

data "kubernetes_service_v1" "nfs" {
  depends_on = [kubernetes_service_v1.nfs]

  metadata {
    name      = "nfs-server"
    namespace = "storage"
  }
}
