module "storage" {
  source = "./modules/storage"
}

module "data" {
  source = "./modules/data"

  postgres_pass = var.postgres_pass
  storage_ip    = module.storage.storage_ip
}
