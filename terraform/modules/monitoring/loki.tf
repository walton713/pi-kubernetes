resource "kubernetes_persistent_volume_v1" "loki" {
  metadata {
    name   = local.loki.name
    labels = local.loki.persistence.labels
  }

  spec {
    access_modes                     = local.loki.persistence.access_modes
    persistent_volume_reclaim_policy = local.loki.persistence.reclaim_policy
    storage_class_name               = local.loki.persistence.storage_class
    volume_mode                      = local.loki.persistence.volume_mode

    capacity = {
      storage = local.loki.persistence.capacity
    }

    persistent_volume_source {
      nfs {
        path   = local.loki.persistence.nfs_path
        server = var.storage_ip
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "loki" {
  depends_on       = [kubernetes_namespace_v1.monitoring, kubernetes_persistent_volume_v1.loki]
  wait_until_bound = true

  metadata {
    name      = local.loki.name
    namespace = local.namespace
  }

  spec {
    access_modes       = local.loki.persistence.access_modes
    storage_class_name = local.loki.persistence.storage_class

    resources {
      requests = {
        storage = local.loki.persistence.capacity
      }
    }

    selector {
      match_labels = local.loki.persistence.labels
    }
  }
}

resource "helm_release" "loki" {
  depends_on = [kubernetes_namespace_v1.monitoring, kubernetes_persistent_volume_claim_v1.loki]
  name       = local.loki.name
  repository = local.loki.repository
  chart      = local.loki.name
  namespace  = local.namespace

  values = [
    yamlencode({
      loki = {
        auth_enabled = false
        commonConfig = {
          replication_factor = 1
        }
        storage = {
          type = "filesystem"
        }
        compactor = {
          retention_enabled    = true
          working_directory    = "/var/loki/retention"
          delete_request_store = "filesystem"
          compaction_interval  = "10m"
        }
        filesystem = {
          chunks_directory = "/var/loki/chunks"
          rules_directory  = "/var/loki/rules"
        }
        schemaConfig = {
          configs = [
            {
              from         = "2024-04-01"
              store        = "tsdb"
              object_store = "filesystem"
              schema       = "v13"
              index = {
                prefix = "index_"
                period = "24h"
              }
            }
          ]
        }
        limits_config = {
          retention_period = "168h"
          allow_deletes    = true
        }
      }
      chunksCache = {
        enabled = false
      }
      resultsCache = {
        enabled = false
      }
      lokiCanary = {
        enabled = true
      }
      resources = {
        limits = {
          cpu    = "100m"
          memory = "128Mi"
        }
        requests = {
          cpu    = "50m"
          memory = "64Mi"
        }
      }
      persistence = {
        enabled = false
      }
      minio = {
        enabled = false
      }
      deploymentMode = "SingleBinary"
      singleBinary = {
        replicas = 1
        persistence = {
          enabled = false
        }
        extraVolumes = [
          {
            name : "loki-storage"
            persistentVolumeClain = {
              claimName = local.loki.name
            }
          }
        ]
        extraVolumeMounts = [
          {
            name      = "loki-storage"
            mountPath = "/var/loki"
          }
        ]
        resources = {
          limits = {
            cpu    = "500m"
            memory = "1Gi"
          }
          requests = {
            cpu    = "100m"
            memory = "512Mi"
          }
        }
      }
      backend = {
        replicas = 0
      }
      read = {
        replicas = 0
      }
      write = {
        replicas = 0
      }
      ingester = {
        replicas = 0
      }
      querier = {
        replicas = 0
      }
      queryFrontend = {
        replicas = 0
      }
      queryScheduler = {
        replicas = 0
      }
      distributor = {
        replicas = 0
      }
      compactor = {
        replicas = 0
      }
      indexGateway = {
        replicas = 0
      }
      bloomCompactor = {
        replicas = 0
      }
      bloomGateway = {
        replicas = 0
      }
    })
  ]
}

resource "helm_release" "promtail" {
  depends_on = [kubernetes_namespace_v1.monitoring, helm_release.loki]
  name       = local.promtail.name
  repository = local.promtail.repository
  chart      = local.promtail.name
  namespace  = local.namespace

  values = [
    yamlencode({
      config = {
        clients = [{
          url = "http://loki-gateway.${local.namespace}.svc.cluster.local/loki/api/v1/push"
        }]
      }

      # Move pipelineStages OUT of snippets to avoid the 'tpl' string error
      pipelineStages = [
        { cri = {} }
      ]

      # Use the chart's built-in extraRelabelConfigs which handles lists correctly
      extraRelabelConfigs = [
        {
          source_labels = ["__meta_kubernetes_pod_label_app"]
          target_label  = "app"
        },
        {
          source_labels = ["__meta_kubernetes_namespace"]
          target_label  = "namespace"
        },
        {
          source_labels = ["__meta_kubernetes_pod_name"]
          target_label  = "pod"
        },
        {
          source_labels = ["__meta_kubernetes_pod_container_name"]
          target_label  = "container"
        }
      ]

      resources = {
        limits   = { cpu = "200m", memory = "256Mi" }
        requests = { cpu = "50m", memory = "128Mi" }
      }

      tolerations = [{
        operator = "Exists"
        effect   = "NoSchedule"
      }]
    })
  ]
}
