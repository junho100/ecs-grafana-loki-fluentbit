resource "aws_service_discovery_http_namespace" "ecs_cluster_namespace" {
  name        = format(module.naming.result, "ecs-cluster-namespace")
  description = "namespace for ecs cluster"
}
