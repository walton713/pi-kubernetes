module "data" {
  source = "./modules/data"

  postgres_pass = var.postgres_pass
  storage_ip    = module.storage.storage_ip
}

module "monitoring" {
  source = "./modules/monitoring"

  grafana_pass = var.grafana_pass
  storage_ip   = module.storage.storage_ip
}

module "storage" {
  source = "./modules/storage"
}
