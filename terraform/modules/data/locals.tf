locals {
  namespace = "data"

  postgres = {
    app  = "postgres"
    name = "postgres"

    deployment = {
      history      = 3
      image        = "postgres:18"
      replicas     = 1
      service_type = "NodePort"

      labels = {
        app  = "postgres"
        name = "postgres"
      }

      port = {
        name      = "postgres"
        node_port = 30432
        port      = 5432
        protocol  = "TCP"
      }

      volume = {
        mount_path = "/var/lib/postgresql"
        name       = "postgres-pvc"
      }
    }

    persistence = {
      access_modes   = ["ReadWriteMany"]
      capacity       = "400Gi"
      nfs_path       = "/postgres"
      reclaim_policy = "Retain"
      storage_class  = "fast"
      volume_mode    = "Filesystem"

      labels = {
        directory = "postgres"
      }
    }
  }
}