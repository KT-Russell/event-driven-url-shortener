module "ecr" {
  source = "../modules/ecr"

  name_prefix = var.name_prefix
  tags        = var.tags
}