locals {
  namespace = "data"

  postgres = {
    app  = "postgres"
    name = "postgres"

    persistence = {
      access_modes = [ "ReadWriteMany" ]
      capacity = "400Gi"
      nfs_path = "/postgres"
      reclaim_policy = "Retain"
      storage_class = "fast"
      volume_mode = "Filesystem"

      labels = {
        directory = "postgres"
      }
    }
  }
}