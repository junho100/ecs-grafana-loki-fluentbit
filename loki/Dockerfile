FROM grafana/loki:2.8.3

COPY ./loki.yml /etc/loki/config.yaml

CMD ["-config.expand-env=true", "-config.file=/etc/loki/config.yaml"]