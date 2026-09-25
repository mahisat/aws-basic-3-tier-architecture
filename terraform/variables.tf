variable "project" {
  type        = string
  description = "Project name used for resource naming"
  default     = "my-project"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type        = string
  description = "Public subnet CIDR block"
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  type        = string
  description = "Primary private subnet CIDR block"
  default     = "10.0.2.0/24"
}

variable "private_subnet_cidr_2" {
  type        = string
  description = "Secondary private subnet CIDR block (required for RDS subnet group)"
  default     = "10.0.3.0/24"
}

variable "db_name" {
  type        = string
  description = "MySQL database name"
  default     = "todo_app"
}

variable "db_username" {
  type        = string
  description = "MySQL master username"
  default     = "dbadmin"
}

variable "db_password" {
  type        = string
  description = "MySQL master password"
  sensitive   = true
}

variable "github_repo_url" {
  type        = string
  description = "Public GitHub repository URL cloned on EC2 instances"
}

variable "frontend_vite_api_base_url" {
  type        = string
  description = "VITE_API_BASE_URL for production frontend build. Use /api with nginx (recommended for public users)."
  default     = "/api"
}

variable "frontend_use_backend_private_api_url" {
  type        = bool
  description = "If true, bake http://<backend private IP>:5000/api into the frontend build (browser must reach that IP; not for public internet)."
  default     = false
}
