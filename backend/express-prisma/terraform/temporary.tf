data "aws_route53_zone" "this" {
  name = var.hosted_zone_name
}
data "aws_alb" "this" {
  name = var.alb_name
}
resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.this.id
  name    = "todolist"
  type    = "A"
  alias {
    name                   = data.aws_alb.this.dns_name
    zone_id                = data.aws_alb.this.zone_id
    evaluate_target_health = true
  }
}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}
resource "aws_alb_target_group" "this" {
  count = 2

  name        = "todolist-${count.index}"
  vpc_id      = data.aws_vpc.this.id
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  health_check {
    path    = "/api/health"
  }
}
data "aws_alb_listener" "https" {
  load_balancer_arn = data.aws_alb.this.arn
  port              = 443
}
resource "aws_alb_listener_rule" "this" {
  listener_arn = data.aws_alb_listener.https.arn
  condition {
    host_header {
      values = [aws_route53_record.this.fqdn]
    }
  }
  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
  action {
    type = "forward"
    forward {
      dynamic "target_group" {
        for_each = aws_alb_target_group.this
        content {
          arn = target_group.value.arn
        }
      }
    }
  }
}

data "aws_ecs_task_definition" "this" {
  task_definition = "todolist-backend-express-prisma"
}
resource "aws_ecs_service" "this" {
  depends_on             = [aws_alb_listener_rule.this]
  name                   = "todolist-backend-express-prisma"
  cluster                = "default"
  desired_count          = 1
  launch_type            = "FARGATE"
  task_definition        = data.aws_ecs_task_definition.this.arn
  enable_execute_command = true
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = var.assign_public_ip
  }
  dynamic "load_balancer" {
    iterator = target_group
    for_each = aws_alb_target_group.this
    content {
      container_name   = "app"
      container_port   = 3000
      target_group_arn = target_group.value.arn
    }
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}
