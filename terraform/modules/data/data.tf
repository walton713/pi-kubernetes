resource "kubernetes_namespace_v1" "data" {
  metadata {
    name = local.namespace
  }
}
