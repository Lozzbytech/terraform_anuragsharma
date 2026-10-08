output "application_load_balancer_url" {
    value = "http://${aws_lb.main.dns_name}"
    description = "entry URL endpoint of the entire platform"
  
}