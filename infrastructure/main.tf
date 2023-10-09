module "naming" {
  source = "./modules/naming"

  environment  = var.environment
  project_name = var.project_name
}
