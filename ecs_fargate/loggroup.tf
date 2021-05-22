resource "aws_cloudwatch_log_group" "x" {
    provider = aws.current
  name = var.ecs_cloudwatchlog_group

  tags = {
    Environment = var.environment
    }
}
