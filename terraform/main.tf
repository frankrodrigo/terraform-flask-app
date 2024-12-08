provider "google" {
  project = "terraform-flask-app-443601"
  region  = "us-central1"
  zone    = "us-central1-a"
}

# Kubernetes Cluster with Smallest Node Configuration
resource "google_container_cluster" "flask_cluster" {
  name               = "flask-cluster"
  location           = var.region
  initial_node_count = 1

  node_config {
    machine_type = "e2-small"  # Smallest machine type for Kubernetes
    disk_size_gb = 10          # Minimum disk size
  }
}

# SQL Server Instance with a Custom Machine Type
resource "google_sql_database_instance" "sql_instance" {
  name             = "flask-sql-instance"
  database_version = "SQLSERVER_2017_STANDARD"
  region           = var.region

  settings {
    tier       = "db-custom-1-3840"  # Smallest supported custom machine type
    disk_size  = 10                  # Minimum disk size
    backup_configuration {
      enabled = false                # Disable backups to save costs
    }
  }

  root_password = "YourRootPassword123!"  # Set a strong root password
}

# SQL Server User
resource "google_sql_user" "sql_user" {
  name     = "dbuser1"  # Matches app secret DB_USER
  password = "dbuser1"  # Matches app secret DB_PASS
  instance = google_sql_database_instance.sql_instance.name
}

# SQL Server Database
resource "google_sql_database" "sql_database" {
  name     = "db1"  # Matches app secret DB_NAME
  instance = google_sql_database_instance.sql_instance.name
}

# Output SQL Server Connection Name
output "db_host" {
  value = google_sql_database_instance.sql_instance.connection_name
}

# Variables for flexibility
variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-a"
}
