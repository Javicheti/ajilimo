provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  name_prefix = "ajilimo-${var.environment}"
  labels = {
    app         = "ajilimo"
    environment = var.environment
    managed_by  = "terraform"
  }
}

# --- APIs requeridas -------------------------------------------------------
resource "google_project_service" "services" {
  for_each = toset([
    "run.googleapis.com",
    "pubsub.googleapis.com",
    "cloudscheduler.googleapis.com",
    "secretmanager.googleapis.com",
    "bigquery.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudtasks.googleapis.com",
    "cloudbuild.googleapis.com",
    "eventarc.googleapis.com",
  ])

  service            = each.value
  disable_on_destroy = false
}

# --- BigQuery (reportes) ---------------------------------------------------
resource "google_bigquery_dataset" "analytics" {
  dataset_id                 = "ajilimo_${var.environment}"
  friendly_name              = "AjíLimo ${var.environment}"
  location                   = "US"
  labels                     = local.labels
  delete_contents_on_destroy = false
}

# --- Pub/Sub (eventos de webhooks y jobs) ----------------------------------
resource "google_pubsub_topic" "events" {
  for_each = toset(["rappi-events", "didi-events", "pedidosya-events", "normalized-orders"])
  name     = "${local.name_prefix}-${each.value}"
  labels   = local.labels
}

resource "google_pubsub_topic" "events_dlq" {
  name   = "${local.name_prefix}-events-dlq"
  labels = local.labels
}

# --- Cloud Scheduler (revisiones periódicas) -------------------------------
resource "google_cloud_scheduler_job" "snapshot_availability" {
  name      = "${local.name_prefix}-snapshot-availability"
  region    = var.region
  schedule  = "*/5 * * * *"
  time_zone = "America/Lima"

  http_target {
    http_method = "POST"
    uri         = "https://${local.name_prefix}-connectors-${var.project_id}.run.app/jobs/snapshot-availability"
    headers = {
      "Content-Type" = "application/json"
    }
  }
}

# --- Secret Manager (contenedor; valores se escriben por API) --------------
resource "google_secret_manager_secret" "tenant_webhook_secret" {
  secret_id = "${local.name_prefix}-webhook-secret-default"
  labels    = local.labels

  replication {
    auto {}
  }
}

# --- Service Account para Cloud Run ----------------------------------------
resource "google_service_account" "connectors" {
  account_id   = "${local.name_prefix}-connectors"
  display_name = "AjíLimo connectors (${var.environment})"
}

resource "google_project_iam_member" "connectors_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.connectors.email}"
}

resource "google_project_iam_member" "connectors_bq_editor" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.connectors.email}"
}

resource "google_project_iam_member" "connectors_pubsub_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.connectors.email}"
}
