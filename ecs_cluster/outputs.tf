output "cluster_arn" {
  description = "Amazon Resource Name for Cluster"
  value = aws_ecs_cluster.x.arn
}

output "cluster_id" {
  description = "ID for Cluster"
  value = aws_ecs_cluster.x.id
}
