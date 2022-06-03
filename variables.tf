variable "enable_platform_services" {
  type    = bool
  default = false # disabled by default because planning the custom resource requires the crd to exist
}

variable "platform_services_values" {
  type    = string
  default = ""
}

variable "platform_services_target_revision" {
  type    = string
  default = ">=1.0.0-alpha"
}

variable "kube_prometheus_stack_chart_version" {
  type    = string
  default = "33.1.0"
}

variable "kube_prometheus_stack_values" {
  type    = list(string)
  default = []
}

variable "argo_cd_chart_version" {
  type    = string
  default = "3.33.8"
}

variable "argo_cd_values" {
  type    = list(string)
  default = []
}

variable "prometheus_remote_write_secret_name" {
  type    = string
  default = "prometheus-remote-write-basic-auth"
}

variable "prometheus_remote_write_username" {
  type      = string
  default   = ""
  sensitive = true
}

variable "prometheus_remote_write_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "manage_kube_prometheus_stack_namespace" {
  description = "Enables management of the kube-prometheus-stack namespace if the remote write secret is being managed"
  type        = bool
  default     = true
}

variable "cert_manager_cloudflare_api_token_secret_name" {
  type    = string
  default = "cloudflare-api-token-secret"
}

variable "cert_manager_cloudflare_api_token" {
  type      = string
  default   = ""
  sensitive = true
}

variable "manage_cert_manager_namespace" {
  description = "Enables management of the cert-manager namespace if the cert manager cloudflare api token secret is being managed"
  type        = bool
  default     = true
}
