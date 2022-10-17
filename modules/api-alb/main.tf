# Application Load Balancer
resource "aws_alb" "alb_application" {
  name            = "${var.application_name}-${terraform.workspace}-${var.random_id_prefix}-alb"
  subnets         = flatten(["${var.public_subnet_ids}"])
  security_groups = flatten(["${var.security_groups_ids}", "${var.ecs_security_group.id}", "${var.alb_security_group.id}"])

  tags = {
    Name        = "${var.application_name}-${terraform.workspace}-${var.random_id_prefix}-alb"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_alb_listener" "application_blue_green" {
  load_balancer_arn = aws_alb.alb_application.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.certificate.arn
  depends_on        = [aws_alb_target_group.alb_target_group_blue]

  default_action {
    target_group_arn = aws_alb_target_group.alb_target_group_blue.arn
    type             = "forward"
  }
}

resource "aws_alb_listener" "application_test_blue_green" {
  load_balancer_arn = aws_alb.alb_application.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.certificate.arn
  depends_on        = [aws_alb_target_group.alb_target_group_blue]

  default_action {
    target_group_arn = aws_alb_target_group.alb_target_group_blue.arn
    type             = "forward"
  }
}

resource "aws_alb_listener" "application_redirection" {
  load_balancer_arn = aws_alb.alb_application.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# AWS ALB Target Blue groups/Listener for Blue/Green Deployments
resource "aws_alb_target_group" "alb_target_group_blue" {
  name        = "${var.application_name}-${terraform.workspace}-tg-${var.random_id_prefix}-blue"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200-399"
    timeout             = "3"
    path                = "/.well-known/apollo/server-health"
    unhealthy_threshold = "2"
  }

  tags = {
    Environment = "${terraform.workspace}-blue"
  }

  depends_on = [aws_alb.alb_application]
}

# AWS ALB Target Green groups/Listener for Blue/Green Deployments
resource "aws_alb_target_group" "alb_target_group_green" {
  name        = "${var.application_name}-${terraform.workspace}-tg-${var.random_id_prefix}-green"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200-399"
    timeout             = "3"
    path                = "/.well-known/apollo/server-health"
    unhealthy_threshold = "2"
  }

  tags = {
    Environment = "${terraform.workspace}-green"
  }

  depends_on = [aws_alb.alb_application]
}

# Standard route53 DNS record for "mystack" pointing to an ALB

data "aws_route53_zone" "platform" {
  name = var.root_domain
}

resource "aws_route53_zone" "platform_sub" {
  name = "${terraform.workspace}.${data.aws_route53_zone.platform.name}"
  depends_on = [
    data.aws_route53_zone.platform
  ]
}

# Sub DNS for API

resource "aws_route53_record" "platform_sub-ns" {
  zone_id = data.aws_route53_zone.platform.zone_id
  name    = aws_route53_zone.platform_sub.name
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.platform_sub.name_servers

}

resource "aws_route53_record" "domain_record" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.platform_sub.zone_id
}

# Sub DNS for API

resource "aws_route53_record" "platform_sub" {
  zone_id = aws_route53_zone.platform_sub.zone_id
  name    = "api.${aws_route53_zone.platform_sub.name}"
  type    = "A"
  alias {
    name                   = aws_alb.alb_application.dns_name
    zone_id                = aws_alb.alb_application.zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "certificate" {
  domain_name               = aws_route53_zone.platform_sub.name
  subject_alternative_names = ["api.${aws_route53_zone.platform_sub.name}", "*.${aws_route53_zone.platform_sub.name}"]
  validation_method         = "DNS"

  tags = {
    Environment = terraform.workspace
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "dns_validation" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.domain_record : record.fqdn]
}

