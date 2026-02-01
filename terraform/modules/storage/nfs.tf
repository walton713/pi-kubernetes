resource "kubernetes_labels" "master_node" {
  api_version = "v1"
  kind        = "Node"

  metadata {
    name = "server"
  }

  labels = {
    hdd = "enabled"
  }
}

resource "kubernetes_namespace_v1" "storage" {
  metadata {
    name = local.namespace
  }
}

resource "kubernetes_persistent_volume_v1" "nfs" {
  metadata {
    name = local.nfs.name

    labels = local.nfs.persistence.labels
  }

  spec {
    access_modes                     = local.nfs.persistence.access_modes
    persistent_volume_reclaim_policy = local.nfs.persistence.reclaim_policy
    storage_class_name               = local.nfs.persistence.storage_class

    capacity = {
      storage = local.nfs.persistence.capacity
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
        path = local.nfs.persistence.local_path
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "nfs" {
  depends_on       = [kubernetes_namespace_v1.storage]
  wait_until_bound = true

  metadata {
    name      = local.nfs.name
    namespace = local.namespace
  }

  spec {
    access_modes       = local.nfs.persistence.access_modes
    storage_class_name = local.nfs.persistence.storage_class

    resources {
      requests = {
        storage = local.nfs.persistence.capacity
      }
    }

    selector {
      match_labels = local.nfs.persistence.labels
    }
  }
}

resource "kubernetes_deployment_v1" "nfs" {
  depends_on       = [kubernetes_namespace_v1.storage, kubernetes_persistent_volume_claim_v1.nfs]
  wait_for_rollout = true

  metadata {
    name      = local.nfs.name
    namespace = local.namespace

    labels = local.nfs.deployment.labels
  }

  spec {
    replicas               = local.nfs.deployment.replicas
    revision_history_limit = local.nfs.deployment.history

    selector {
      match_labels = local.nfs.deployment.labels
    }

    template {
      metadata {
        labels = local.nfs.deployment.labels
      }

      spec {
        container {
          image = local.nfs.deployment.image
          name  = local.nfs.name

          env {
            name  = "SHARED_DIRECTORY"
            value = local.nfs.deployment.volume.mount_path
          }

          port {
            container_port = local.nfs.deployment.nfs_port.port
            name           = local.nfs.deployment.nfs_port.name
          }

          port {
            container_port = local.nfs.deployment.mountd_port.port
            name           = local.nfs.deployment.mountd_port.name
          }

          port {
            container_port = local.nfs.deployment.rpcbind_port.port
            name           = local.nfs.deployment.rpcbind_port.name
          }

          security_context {
            privileged = true
          }

          volume_mount {
            mount_path = local.nfs.deployment.volume.mount_path
            name       = local.nfs.deployment.volume.name
          }
        }

        node_selector = local.nfs.deployment.node_selector

        volume {
          name = local.nfs.deployment.volume.name

          persistent_volume_claim {
            claim_name = local.nfs.name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "nfs" {
  depends_on = [kubernetes_namespace_v1.storage, kubernetes_deployment_v1.nfs]

  metadata {
    name      = local.nfs.name
    namespace = local.namespace

    labels = local.nfs.deployment.labels
  }

  spec {
    type = local.nfs.deployment.service_type

    port {
      name = local.nfs.deployment.nfs_port.name
      port = local.nfs.deployment.nfs_port.port
    }

    port {
      name = local.nfs.deployment.mountd_port.name
      port = local.nfs.deployment.mountd_port.port
    }

    port {
      name = local.nfs.deployment.rpcbind_port.name
      port = local.nfs.deployment.rpcbind_port.port
    }

    selector = local.nfs.deployment.labels
  }
}

data "kubernetes_service_v1" "nfs" {
  depends_on = [kubernetes_service_v1.nfs]

  metadata {
    name      = local.nfs.name
    namespace = local.namespace
  }
}
