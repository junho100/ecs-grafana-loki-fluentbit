#!/bin/bash
cat <<'EOF' >> /etc/ecs/ecs.config
ECS_CLUSTER=test
ECS_LOGLEVEL=debug
ECS_ENABLE_TASK_IAM_ROLE=true
EOF