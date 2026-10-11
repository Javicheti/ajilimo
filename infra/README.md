# Infraestructura — AjíLimo (Terraform)

Base de infraestructura en Google Cloud para AjíLimo (dev).

## Requisitos
- Terraform >= 1.6
- `gcloud` autenticado con la cuenta del proyecto y la config nombrada:
  ```bash
  gcloud --configuration=ajilimo auth login javicheti001@gmail.com
  gcloud --configuration=ajilimo config set project ajilimo-830ca
  ```

## Uso
```bash
cd infra
gcloud --configuration=ajilimo auth application-default login
terraform init
terraform plan  -var="project_id=ajilimo-830ca" -var="environment=dev"
terraform apply -var="project_id=ajilimo-830ca" -var="environment=dev"
```

## Qué crea
- APIs habilitadas (Run, Pub/Sub, Scheduler, Secret Manager, BigQuery, Functions, Tasks, Eventarc).
- Dataset **BigQuery** (`ajilimo_dev`) para reportes.
- Tópicos **Pub/Sub** por canal + DLQ.
- Job de **Cloud Scheduler** (`snapshot-availability`, cada 5 min).
- Contenedor base de **Secret Manager** y **service account** de conectores con permisos
  mínimos (Secret Accessor, BigQuery Data Editor, Pub/Sub Publisher).

> El estado remoto (`backend "gcs"`) queda comentado hasta crear el bucket de estado.
