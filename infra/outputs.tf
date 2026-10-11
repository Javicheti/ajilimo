output "bigquery_dataset" {
  description = "Dataset de BigQuery para analítica."
  value       = google_bigquery_dataset.analytics.dataset_id
}

output "pubsub_topics" {
  description = "Tópicos de Pub/Sub creados."
  value       = [for t in google_pubsub_topic.events : t.name]
}

output "connectors_service_account" {
  description = "Service account de los conectores."
  value       = google_service_account.connectors.email
}
