output "express_frontend_url" {
  value       = "http://${aws_instance.frontend_server.public_ip}:3000"
  description = "Public URL to access your Express UI layer"
}

output "flask_backend_url" {
  value       = "http://${aws_instance.backend_server.public_ip}:5000/api/message"
  description = "Public URL to test your Flask REST interface endpoints"
}
