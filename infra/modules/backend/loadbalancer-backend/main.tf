resource "aws_lb_target_group" "back_end" {
  name     = var.target_group_name
  port     = 8084
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  #adding health check path
  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }  
}

resource "aws_lb" "back_end" {
  name               = var.alb_name
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnets

  tags = {
    Name = var.alb_name
  }
  depends_on = [aws_lb_target_group.back_end]
}

resource "aws_lb_listener" "back_end" {
  load_balancer_arn = aws_lb.back_end.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.back_end.arn
  }
  depends_on = [aws_lb_target_group.back_end]
}
