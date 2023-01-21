provider "google" {
  project = local.project
  region  = var.region
}

terraform {
  required_providers {
    google = {
      version = "~> 4.8.0"
    }
  }
}
