locals {
  namespace = "storage"

  nfs = {
    name = "nfs"

    deployment = {
      history      = 3
      image        = "itsthenetwork/nfs-server-alpine:11-arm"
      replicas     = 1
      service_type = "ClusterIP"

      labels = {
        app  = "nfs"
        name = "nfs-server"
      }

      mountd_port = {
        name = "mountd"
        port = 20048
      }

      nfs_port = {
        name = "nfs"
        port = 2049
      }

      node_selector = {
        hdd = "enabled"
      }

      rpcbind_port = {
        name = "rpcbind"
        port = 111
      }

      volume = {
        mount_path = "/exports"
        name       = "nfs-pvc"
      }
    }

    persistence = {
      access_modes   = ["ReadWriteOnce"]
      capacity       = "800Gi"
      local_path     = "/mnt/data"
      reclaim_policy = "Retain"
      storage_class  = "local-storage"

      labels = {
        directory = "data"
      }
    }
  }
}
