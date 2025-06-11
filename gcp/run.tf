# Create Cloud Run Service
resource "google_cloud_run_v2_service" "juicebox" {
  name                = "juicebox"
  location            = var.region
  deletion_protection = false
  ingress             = "INGRESS_TRAFFIC_ALL"

  scaling {
    manual_instance_count = 0
    min_instance_count    = 4
  }

  template {
    containers {
      image = "${var.image_url}:${var.image_version}"
      name  = "juicebox-1"
      env {
        name  = "BIGTABLE_INSTANCE_ID"
        value = "jb-sw-realms"
      }
      env {
        name  = "GCP_PROJECT_ID"
        value = var.project_id
      }
      env {
        name  = "PROVIDER"
        value = "gcp"
      }
      env {
        name  = "REALM_ID"
        value = var.realm_id
      }
    }
  }
}

resource "google_project_iam_binding" "logs_writer_binding" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  members = [
    "serviceAccount:${google_service_account.service_account.email}"
  ]
}
