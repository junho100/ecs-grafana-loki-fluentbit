resource "grafana_dashboard" "loki_dashboard" {
  config_json = templatefile("./files/loki-dashboard.tftpl", {
    loki_datasource_uid = grafana_data_source.grafana_loki_datasource.uid
  })
}

resource "grafana_data_source" "grafana_loki_datasource" {
  type = "loki"
  name = "Loki"

  access_mode = "proxy"
  url         = "http://loki:3100"
}
