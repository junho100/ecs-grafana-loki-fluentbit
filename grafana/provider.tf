terraform {
  required_providers {
    grafana = {
      source = "grafana/grafana"
    }
  }
  required_version = ">= 1.0"
}

provider "grafana" {
  url  = "https://monit-${var.environment}.${var.domain_name}"
  auth = "${var.grafana_id}:${var.grafana_pw}"
}
