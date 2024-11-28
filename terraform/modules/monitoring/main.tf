resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "monitoring"

    labels = {
      app = "monitoring"
    }
  }
}

resource "kubernetes_config_map_v1" "prometheus-config" {
  metadata {
    name      = "prometheus-config"
    namespace = "monitoring"
  }

  data = {
    "prometheus.yaml" = "${file("${path.module}/prometheus.yaml")}"
  }
}

resource "kubernetes_deployment_v1" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = "monitoring"

    labels = {
      app = "prometheus"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "prometheus"
      }
    }

    template {
      metadata {
        labels = {
          app = "prometheus"
        }
      }

      spec {
        container {
          name  = "prometheus"
          image = "prom/prometheus"

          port {
            name           = "prometheus"
            container_port = 9090
          }

          volume_mount {
            name       = "config-volume"
            mount_path = "/etc/prometheus/prometheus.yml"
            sub_path   = "prometheus.yaml"
          }
        }

        volume {
          name = "config-volume"
          config_map {
            name = "prometheus-config"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = "monitoring"
  }

  spec {
    type = "ClusterIP"

    port {
      name        = "promui"
      protocol    = "TCP"
      port        = 9090
      target_port = 9090
    }

    selector = {
      app = "prometheus"
    }
  }
}

resource "kubernetes_persistent_volume_v1" "grafana-nfs-pv" {
  metadata {
    name = "grafana-nfs-pv"

    labels = {
      directory = "grafana"
    }
  }

  spec {
    access_modes                     = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "slow"
    volume_mode                      = "Filesystem"

    capacity = {
      storage = "1Gi"
    }

    persistent_volume_source {
      nfs {
        path   = "/grafana"
        server = var.nfs_server_ip
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "grafana-nfs-pvc" {
  metadata {
    name      = "grafana-nfs-pvc"
    namespace = "monitoring"
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "slow"

    resources {
      requests = {
        storage = "1Gi"
      }
    }

    selector {
      match_labels = {
        directory = "grafana"
      }
    }
  }
}

resource "kubernetes_deployment_v1" "grafana" {
  metadata {
    name      = "grafana"
    namespace = "monitoring"

    labels = {
      app = "grafana"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "grafana"
      }
    }

    template {
      metadata {
        labels = {
          app  = "grafana"
          name = "grafana"
        }
      }

      spec {
        container {
          name              = "grafana"
          image             = "grafana/grafana"
          image_pull_policy = "Always"

          port {
            name           = "grafana"
            container_port = 3000
          }

          security_context {
            privileged = true
          }

          volume_mount {
            name       = "grafana-nfs-pv"
            mount_path = "/var/lib/grafana"
          }
        }

        volume {
          name = "grafana-nfs-pv"
          persistent_volume_claim {
            claim_name = "grafana-nfs-pvc"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "grafana" {
  metadata {
    name      = "grafana"
    namespace = "monitoring"
  }

  spec {
    type = "ClusterIP"

    port {
      name        = "grafana"
      protocol    = "TCP"
      port        = 3000
      target_port = 3000
    }

    selector = {
      app = "grafana"
    }
  }
}

resource "kubernetes_ingress_v1" "grafana-ingress" {
  metadata {
    name      = "grafana-ingress"
    namespace = "monitoring"

    annotations = {
      "kubernetes.io/ingress-class"                  = "nginx"
    #   "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "grafana.local"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "grafana"

              port {
                number = 3000
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "prom-ingress" {
  metadata {
    name      = "prom-ingress"
    namespace = "monitoring"

    annotations = {
      "kubernetes.io/ingress-class"                  = "nginx"
    #   "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "prom.local"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "prometheus"

              port {
                number = 9090
              }
            }
          }
        }
      }
    }
  }
}
