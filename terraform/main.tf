terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~>3.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"

  registry_auth {
    address       = "http://192.168.0.102:32000"
    auth_disabled = true
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "microk8s"
}

module "database" {
  source = "./modules/database"

  providers = {
    docker = docker
  }

  nfs_server_ip       = module.storage.storage_ip
  mysql_root_password = var.mysql_root_password
}

# module "docker" {
#   source = "./modules/docker"

#   nfs_server_ip = module.storage.storage_ip
# }

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
