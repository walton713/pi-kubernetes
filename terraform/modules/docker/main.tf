resource "kubernetes_namespace_v1" "docker" {
  metadata {
    name = "docker"

    labels = {
      app = "docker_registry"
    }
  }
}

resource "kubernetes_persistent_volume_v1" "docker-nfs-pv" {
  metadata {
    name = "docker-nfs-pv"

    labels = {
      directory = "docker"
    }
  }

  spec {
    access_modes                     = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "slow"
    volume_mode                      = "Filesystem"

    capacity = {
      storage = "10Gi"
    }

    persistent_volume_source {
      nfs {
        path   = "/docker"
        server = var.nfs_server_ip
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "docker-nfs-pvc" {
  metadata {
    name      = "docker-nfs-pvc"
    namespace = "docker"
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "slow"

    resources {
      requests = {
        storage = "10Gi"
      }
    }

    selector {
      match_labels = {
        directory = "docker"
      }
    }
  }
}

resource "kubernetes_deployment_v1" "registry" {
  metadata {
    name      = "registry"
    namespace = "docker"

    labels = {
      app = "docker_registry"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "docker_registry"
      }
    }

    template {
      metadata {
        labels = {
          app  = "docker_registry"
          name = "registry"
        }
      }

      spec {
        container {
          name              = "registry"
          image             = "registry"
          image_pull_policy = "Always"

          port {
            name           = "registry"
            container_port = 5000
          }

          volume_mount {
            name       = "docker-nfs-pv"
            mount_path = "/var/lib/registry"
          }
        }

        volume {
          name = "docker-nfs-pv"

          persistent_volume_claim {
            claim_name = "docker-nfs-pvc"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "registry" {
  metadata {
    name      = "registry"
    namespace = "docker"
  }

  spec {
    type = "ClusterIP"

    port {
      name        = "registry"
      protocol    = "TCP"
      port        = 5000
      target_port = 5000
    }

    selector = {
      app = "docker_registry"
    }
  }
}

resource "kubernetes_ingress_v1" "registry-ingress" {
  metadata {
    name      = "registry-ingress"
    namespace = "docker"

    annotations = {
      "kubernetes.io/ingress-class"                  = "nginx"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "registry.local"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "registry"

              port {
                number = 5000
              }
            }
          }
        }
      }
    }
  }
}
