variable "project_id" {
  description = "ID del proyecto de Google Cloud / Firebase."
  type        = string
  default     = "ajilimo-830ca"
}

variable "region" {
  description = "Región principal de despliegue."
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Entorno (dev | prod)."
  type        = string
  default     = "dev"
}
