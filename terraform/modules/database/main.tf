terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~>3.0"
    }
  }
}

locals {
  migrations_path = "mnt/c/Users/walto/Documents/Projects/server/src/migrations/migrations"
}

resource "kubernetes_namespace_v1" "database" {
  metadata {
    name = "database"

    labels = {
      app = "database"
    }
  }
}

resource "kubernetes_persistent_volume_v1" "mysql-nfs-pv" {
  metadata {
    name = "mysql-nfs-pv"

    labels = {
      directory = "mysql"
    }
  }

  spec {
    access_modes                     = ["ReadWriteMany"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "fast"
    volume_mode                      = "Filesystem"

    capacity = {
      storage = "50Gi"
    }

    persistent_volume_source {
      nfs {
        path   = "/mysql"
        server = var.nfs_server_ip
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "mysql-nfs-pvc" {
  metadata {
    name      = "mysql-nfs-pvc"
    namespace = "database"
  }

  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "fast"

    resources {
      requests = {
        storage = "50Gi"
      }
    }

    selector {
      match_labels = {
        directory = "mysql"
      }
    }
  }
}

resource "kubernetes_deployment_v1" "mysql" {
  metadata {
    name      = "mysql"
    namespace = "database"

    labels = {
      app = "mysql"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "mysql"
      }
    }

    template {
      metadata {
        labels = {
          app  = "mysql"
          name = "mysql"
        }
      }

      spec {
        container {
          name              = "mysql"
          image             = "mysql:9"
          image_pull_policy = "Always"

          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value = var.mysql_root_password
          }

          port {
            container_port = 3306
          }

          volume_mount {
            name       = "mysql-nfs-pv"
            mount_path = "/var/lib/mysql"
          }
        }

        volume {
          name = "mysql-nfs-pv"

          persistent_volume_claim {
            claim_name = "mysql-nfs-pvc"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "mysql" {
  metadata {
    name      = "mysql"
    namespace = "database"

    labels = {
      app = "mysql"
    }
  }

  spec {
    type = "LoadBalancer"

    port {
      name        = "mysql"
      protocol    = "TCP"
      port        = 3306
      target_port = 3306
    }

    selector = {
      app = "mysql"
    }
  }
}

# docker image

resource "docker_image" "migrations" {
  name         = "192.168.0.102:32000/migrations:latest"
  keep_locally = false

  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(local.migrations_path, "*") : filesha1("${local.migrations_path}/${f}")]))
  }

  build {
    context  = "../src/migrations"
    tag      = ["192.168.0.102:32000/migrations:latest"]
    no_cache = true

    auth_config {
      host_name = "http://192.168.0.102:32000"
    }
  }
}

resource "docker_registry_image" "migrations_path" {
  name                 = docker_image.migrations.name
  insecure_skip_verify = true
}

# job
