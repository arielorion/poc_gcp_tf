# Define the provider (Google Cloud)
provider "google" {
  credentials = var.GOOGLE_CREDENTIALS
  project    = var.project_name
  region     = var.region
}

# Create a VPC network
resource "google_compute_network" "my_network" {
  name = "my-network"
}

# Create subnetworks for each tier
resource "google_compute_subnetwork" "web" {
  name          = "web-subnetwork"
  network       = google_compute_network.my_network.self_link
  ip_cidr_range = "10.0.1.0/24"
}

resource "google_compute_subnetwork" "app" {
  name          = "app-subnetwork"
  network       = google_compute_network.my_network.self_link
  ip_cidr_range = "10.0.2.0/24"
}

resource "google_compute_subnetwork" "db" {
  name          = "db-subnetwork"
  network       = google_compute_network.my_network.self_link
  ip_cidr_range = "10.0.3.0/24"
}

# Create a PostgreSQL database
resource "google_sql_database_instance" "my_database" {
  name             = "my-database"
  database_version = "POSTGRES_13"
  region           = var.region
  settings {
    tier = "db-f1-micro"
  }
}

# Create an App Engine application
resource "google_app_engine_application" "my_app" {
  project     = var.project_name
  location_id = "us-central"
}

# Configure the App Engine services
resource "google_app_engine_service" "web_app" {
  project     = google_app_engine_application.my_app.project
  location_id = google_app_engine_application.my_app.location_id
  service_id  = "web-app"
  runtime     = "python39" # You can use the appropriate runtime
}

resource "google_app_engine_service" "app_service" {
  project     = google_app_engine_application.my_app.project
  location_id = google_app_engine_application.my_app.location_id
  service_id  = "app-service"
  runtime     = "python39" # You can use the appropriate runtime
}

# Define firewall rules to allow traffic
resource "google_compute_firewall" "allow-http" {
  name    = "allow-http"
  network = google_compute_network.my_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Output the database connection name
output "database_connection_name" {
  value = google_sql_database_instance.my_database.connection_name
}
