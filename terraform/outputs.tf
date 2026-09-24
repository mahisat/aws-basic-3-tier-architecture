output "frontend_public_ip" {
  description = "Public IP of the frontend EC2 instance"
  value       = aws_instance.web_server.public_ip
}

output "backend_private_ip" {
  description = "Private IP of the backend EC2 instance"
  value       = aws_instance.backend_server.private_ip
}

output "rds_endpoint" {
  description = "RDS MySQL connection endpoint (host:port)"
  value       = aws_db_instance.database.endpoint
  sensitive   = true
}

output "deployer_key_pem_path" {
  description = "Local path to the generated SSH private key (add contents to GitHub secret EC2_PRIVATE_KEY)"
  value       = local_file.main_private_key.filename
}

output "frontend_instance_id" {
  description = "Frontend EC2 instance ID"
  value       = aws_instance.web_server.id
}

output "backend_instance_id" {
  description = "Backend EC2 instance ID (target for SSM deploy)"
  value       = aws_instance.backend_server.id
}
