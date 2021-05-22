resource "aws_ecs_cluster" "x" {
  provider = aws.current
  name = "${var.cluster_name}-${var.environment}-cluster"
  tags = {
      Name = var.cluster_tag_name
      Env = var.environment
  }
}
