# Configure the Azure provider
terraform {
  required_providers {

    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "2.12.0"
    }
  }
}
