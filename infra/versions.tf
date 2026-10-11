terraform {
  required_version = ">= 1.6"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  # Backend remoto (habilitar cuando exista el bucket de estado):
  # backend "gcs" {
  #   bucket = "ajilimo-830ca-tfstate"
  #   prefix = "ajilimo"
  # }
}
