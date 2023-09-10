[
  {
    "name": "grafana",
    "image": "grafana/grafana:latest",
    "cpu": 0,
    "portMappings": [
      {
        "name": "grafana-3000-tcp",
        "containerPort": 3000,
        "hostPort": 3000,
        "protocol": "tcp",
        "appProtocol": "http"
      }
    ],
    "essential": true,
    "environment": [
      {
        "name": "GF_AUTH_ANONYMOUS_ORG_ROLE",
        "value": "Admin"
      },
      {
        "name": "GF_AUTH_ANONYMOUS_ENABLED",
        "value": "true"
      }
    ]
  }
]
