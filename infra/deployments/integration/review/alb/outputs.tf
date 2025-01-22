output "alb_dns_name" {
  description = "The DNS name of the application load balancer"
  value       = aws_lb.load_balancer.dns_name
}

output "alb_tls_listener_id" {
  description = "The id of the ALB listener that listens with the TLS certificate"
  value       = aws_lb_listener.tls_listener.id
}
