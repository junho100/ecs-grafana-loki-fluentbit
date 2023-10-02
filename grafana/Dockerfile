FROM grafana/grafana:latest

RUN mkdir -p /etc/grafana/provisioning/datasources

COPY ./grafana-loki-datasource.yml /etc/grafana/provisioning/datasources/

ENTRYPOINT [ "/run.sh" ]