# deploy prometheus remote write configuration secret
locals {
  enable_prometheus_remote_write_secret = (
    var.prometheus_remote_write_username != "" && var.prometheus_remote_write_password != ""
  )
}

resource "kubernetes_namespace_v1" "kube_prometheus_stack" {
  count = local.enable_prometheus_remote_write_secret && var.manage_kube_prometheus_stack_namespace ? 1 : 0
  metadata {
    name = "kube-prometheus-stack"
  }
}

resource "kubernetes_secret_v1" "prometheus_remote_write" {
  count = local.enable_prometheus_remote_write_secret ? 1 : 0

  metadata {
    name      = var.prometheus_remote_write_secret_name
    namespace = "kube-prometheus-stack"
  }

  data = {
    username = var.prometheus_remote_write_username
    password = var.prometheus_remote_write_password
  }

  depends_on = [
    kubernetes_namespace_v1.kube_prometheus_stack
  ]
}

# deploy kube-prometheus-stack
resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  chart            = "kube-prometheus-stack"
  namespace        = "kube-prometheus-stack"
  create_namespace = true
  repository       = "https://prometheus-community.github.io/helm-charts"
  version          = var.kube_prometheus_stack_chart_version
  values           = var.kube_prometheus_stack_values

  # disables waiting for all resources to be deployed successfully
  wait = false

  depends_on = [
    kubernetes_secret_v1.prometheus_remote_write
  ]
}

# deploy argocd
resource "helm_release" "argo_cd" {
  name             = "argo-cd"
  chart            = "argo-cd"
  namespace        = "argo-cd"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  version          = var.argo_cd_chart_version
  values           = var.argo_cd_values

  # disables waiting for all resources to be deployed successfully
  wait = false

  depends_on = [
    # depend on prometheus so that we can deploy ServiceMonitor custom
    # resources with the argo_cd helm release
    helm_release.kube_prometheus_stack
  ]
}

# deploy cert manager dns solver secret
locals {
  enable_cert_manager_cloudflare_api_token_secret = var.cert_manager_cloudflare_api_token != ""
}

resource "kubernetes_namespace_v1" "cert_manager" {
  count = local.enable_cert_manager_cloudflare_api_token_secret && var.manage_cert_manager_namespace ? 1 : 0
  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_secret_v1" "cert_manager_cloudflare_api_token" {
  count = local.enable_cert_manager_cloudflare_api_token_secret ? 1 : 0

  metadata {
    name      = var.cert_manager_cloudflare_api_token_secret_name
    namespace = "cert-manager"
  }

  data = {
    api-token = var.cert_manager_cloudflare_api_token
  }

  depends_on = [
    kubernetes_namespace_v1.cert_manager
  ]
}

# deploy platform cluster application
module "platform_services" {
  count = var.enable_platform_services ? 1 : 0

  source  = "catalystcommunity/argocd-application/kubernetes"
  version = "1.0.1"

  name                   = "platform-services"
  source_chart           = "platform-services"
  source_repo_url        = "https://raw.githubusercontent.com/catalystcommunity/charts/main"
  source_target_revision = var.platform_services_target_revision
  helm_values            = var.platform_services_values

  depends_on = [
    helm_release.argo_cd,
    kubernetes_secret_v1.prometheus_remote_write,
    kubernetes_secret_v1.cert_manager_cloudflare_api_token,
  ]
}
