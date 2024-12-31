provider "aws" {
  region = "eu-west-2"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "http-bucket-task"
}

resource "aws_security_group" "http_access" {
  vpc_id      = "vpc-0f9cd5cef10531b66"
  name = "http-https-access"
  description = "Allow HTTP and HTTPS traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "http_service_lb" {
  name               = "http-service-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.http_access.id]
  subnets            = ["subnet-0a51bf48a50e26bc8", "subnet-0682f706051fc0a65"]
}

resource "aws_lb_target_group" "http_service_tg" {
  name     = "http-service-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = "vpc-0f9cd5cef10531b66"
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.http_service_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:eu-west-2:975050266364:certificate/931dc2e2-aa2f-44f6-8ab1-6f7f956cecf7"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http_service_tg.arn
  }
}

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.http_service_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      protocol   = "HTTPS"
      port       = "443"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_route53_record" "api_alias" {
  zone_id = "Z096980623E5FIEHE257C"
  name    = "api.list-bucket.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.http_service_lb.dns_name]
}

output "alb_dns_name" {
  value = aws_lb.http_service_lb.dns_name
}
