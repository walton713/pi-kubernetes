module "data" {
  depends_on = [module.storage]
  source     = "./modules/data"

  postgres_pass = var.postgres_pass
  storage_ip    = module.storage.storage_ip
}

module "monitoring" {
  depends_on = [module.storage]
  source     = "./modules/monitoring"

  grafana_pass  = var.grafana_pass
  postgres_pass = var.postgres_pass
  storage_ip    = module.storage.storage_ip
}

module "storage" {
  source = "./modules/storage"
}
