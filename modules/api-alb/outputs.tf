output "aws_target_group_blue" {
  value = aws_alb_target_group.alb_target_group_blue
}

output "aws_target_group_green" {
  value = aws_alb_target_group.alb_target_group_green
}

output "aws_alb_blue_green" {
  value = aws_alb_listener.application_blue_green
}

output "aws_alb_test_blue_green" {
  value = aws_alb_listener.application_test_blue_green
}

output "route53" {
  value = aws_route53_record.platform_sub
}
