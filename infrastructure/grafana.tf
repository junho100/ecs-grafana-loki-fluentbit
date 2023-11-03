resource "grafana_dashboard" "loki_dashboard" {
  config_json = file("./files/loki-dashboard.json")

  depends_on = [module.ecs_grafana_service, grafana_data_source.grafana_loki_datasource]
}

resource "grafana_data_source" "grafana_loki_datasource" {
  type = "loki"
  name = "Loki"

  access_mode = "proxy"
  url         = "http://loki:3100"

  depends_on = [module.ecs_grafana_service, module.ecs_loki_service]
}
