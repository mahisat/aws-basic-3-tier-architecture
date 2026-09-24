
variable "project"{
    type        = string
    description = "Project Name"
    default     = "my-project"
}

variable "region" {
  type        = string
  description = "AWS Regios"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR Block"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
    type        = string
    description = "Public Subnet CIDR Block"
    default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
    type        = string
    description = "Private Subnet CIDR Block"
    default     = "10.0.2.0/24"
}

variable "db_name" {
    type        = string
    description = "Database Name"
    default     = "my-database"
}
variable "db_username" {
    type        = string
    description = "Database Username"
    default     = "admin"
}

variable "db_password" {
    type        = string
    description = "Database Password"
    default     = "admin123"
}

variable "github_repo_url" {
    type        = string
    description = "GitHub Repository URL"
    default     = "https://github.com/your-username/your-repo.git"
}
