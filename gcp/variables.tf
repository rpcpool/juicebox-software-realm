variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "realm_id" {
  description = "A 16-byte hex string that identifies your realm"
  type        = string
}

variable "region" {
  description = "Google Cloud Region"
  type        = string
}

variable "zone" {
  description = "Google Cloud Zone"
  type        = string
}

variable "tenant_secrets" {
  description = "The names of any tenants you will be allowing access to (alphanumeric) mapped to their auth signing key. Read the 'Tenant Auth Secrets' section of the README for more details."
  type        = map(string)
}

variable "juicebox_image_url" {
  description = "The url of the juicebox docker image"
  type        = string
}

variable "juicebox_image_version" {
  description = "The version of the juicebox docker image"
  type        = string
}

variable "juicebox_vars" {
  description = "Environment variables for the juicebox container"
  type        = map(string)
  default     = {}
}

variable "otelcol_image_url" {
  description = "The url of the opentelemetry collector docker image"
  type        = string
}

variable "otelcol_image_version" {
  description = "The version of the opentelemetry collector docker image"
  type        = string
}

variable "otelcol_config_b64" {
  description = "A configuration file for the OpenTelemetry Collector, encoded in base64"
  type        = string
  default     = "INTERNAL"
  # This default is captured in secret-manager.tf to deploy ../otel-collector-config.yaml from this repository.
}

variable "otelcol_vars" {
  description = "Environment variables for the juicebox container"
  type        = map(string)
  default     = {}
}
