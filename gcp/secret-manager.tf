resource "google_secret_manager_secret" "secret" {
  for_each  = var.tenant_secrets
  secret_id = "jb-sw-tenant-${each.key}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "secret" {
  for_each    = var.tenant_secrets
  secret      = google_secret_manager_secret.secret[each.key].id
  secret_data = each.value
}

resource "google_secret_manager_secret_iam_binding" "access" {
  for_each  = var.tenant_secrets
  secret_id = google_secret_manager_secret.secret[each.key].id
  role      = "roles/secretmanager.secretAccessor"

  members = [
    "serviceAccount:${google_service_account.service_account.email}"
  ]
}
