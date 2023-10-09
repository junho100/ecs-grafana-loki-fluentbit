locals {
  resource_name = "%s"
  result        = "${var.environment}-${var.project_name}${random_string.random.result}-${local.resource_name}"
}

resource "random_string" "random" {
  length      = 3
  numeric     = true
  min_numeric = 3
}
