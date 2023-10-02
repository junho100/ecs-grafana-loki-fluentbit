resource "aws_service_discovery_http_namespace" "ecs_cluster_namespace" {
  name        = "test-cluster-namespace"
  description = "test"
}
