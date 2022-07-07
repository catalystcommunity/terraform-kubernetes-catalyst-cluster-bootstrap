variable "enable_platform_services" {
  description = "Whether to deploy the chart-platform-services ArgoCD application custom resource."
  type        = bool
  default     = true
}

variable "platform_services_values" {
  description = "Values to pass to the chart-platform-services ArgoCD application."
  type        = string
  default     = ""
}

variable "platform_services_target_revision" {
  description = "Target revision of the chart-platform-services ArgoCD application."
  type        = string
  default     = ">=1.0.0-alpha"
}

variable "kube_prometheus_stack_chart_version" {
  description = "Version of the kube-prometheus-stack helm chart to deploy."
  type        = string
  default     = "33.1.0"
}

variable "kube_prometheus_stack_values" {
  description = "Values of the kube-prometheus-stack helm chart to deploy."
  type        = list(string)
  default     = []
}

variable "argo_cd_chart_version" {
  description = "Version of the argo-cd helm chart to deploy."
  type        = string
  default     = "3.33.8"
}

variable "argo_cd_values" {
  description = "Values of the argo-cd helm chart to deploy."
  type        = list(string)
  default     = []
}

variable "prometheus_remote_write_secret_name" {
  description = "Name of Kubernetes secret to create for managing Prometheus remote write authentication credentials."
  type        = string
  default     = "prometheus-remote-write-basic-auth"
}

variable "prometheus_remote_write_username" {
  description = "Basic auth username to configure in the Prometheus remote write secret. Disabled if not supplied."
  type        = string
  default     = ""
  sensitive   = true
}

variable "prometheus_remote_write_password" {
  description = "Basic auth password to configure in the Prometheus remote write secret. Disabled if not supplied."
  type        = string
  default     = ""
  sensitive   = true
}

variable "manage_kube_prometheus_stack_namespace" {
  description = "Enables management of the kube-prometheus-stack namespace if the remote write secret is being managed"
  type        = bool
  default     = true
}

variable "cert_manager_cloudflare_api_token_secret_name" {
  description = "Name of Kubernetes secret to create for managing a Cert Manager CloudFlare API token."
  type        = string
  default     = "cloudflare-api-token-secret"
}

variable "cert_manager_cloudflare_api_token" {
  description = "CloudFlare API token to configure in the Cert Manager CloudFlare API token secret. Disabled if not supplied."
  type        = string
  default     = ""
  sensitive   = true
}

variable "manage_cert_manager_namespace" {
  description = "Enables management of the cert-manager namespace if the cert manager cloudflare api token secret is being managed"
  type        = bool
  default     = true
}
