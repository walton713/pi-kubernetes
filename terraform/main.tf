provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "microk8s"
}

module "monitoring" {
  source = "./modules/monitoring"

  nfs_server_ip = module.storage.storage_ip
}

module "storage" {
  source = "./modules/storage"
}

resource "kubernetes_ingress_v1" "dashboard-ingress" {
  metadata {
    name      = "dashboard-ingress"
    namespace = "kube-system"

    annotations = {
      "kubernetes.io/ingress.class"                  = "nginx"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "dashboard.local"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "kubernetes-dashboard"

              port {
                number = 443
              }
            }
          }
        }
      }
    }
  }
}
