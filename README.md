# terraform-k8s-catalyst-cluster-bootstrap

The module provisions Kubernetes resources for "bootstrapping" a Kubernetes
cluster. The bootstrap process installs open source tools for operating and
monitoring Kubernetes, including the following:

* [Argo CD](https://argo-cd.readthedocs.io/en/stable/)
* [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack), deployed outside of the chart-platform-services helm chart to allow for Prometheus custom resources to be deployed successfully if enabled in the ArgoCD helm chart.
* [chart-platform-services](https://github.com/catalystsquad/chart-platform-services) from Catalyst Squad, which includes various other open-source tools deployed via an [ArgoCD app of apps pattern](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/#app-of-apps-pattern).
* External dependencies for software contained in chart-platform-services including resources such as secrets which are not managed by the helm charts implemented in the charts.


## Example Implementations

### Basic

Supply values to additional functionality that you require. Prometheus, ArgoCD,
and platform-services helm chart will be deployed by default:
```terraform
module "bootstrap" {
  source = "github.com/catalystsquad/terraform-k8s-catalyst-cluster-bootstrap"

  prometheus_remote_write_username  = var.prometheus_remote_write_username
  prometheus_remote_write_password  = var.prometheus_remote_write_password
  cert_manager_cloudflare_api_token = var.cert_manager_cloudflare_api_token
}
```

### Secret Replacement in values file

You can make use of the built-in [templatefile()](https://www.terraform.io/language/functions/templatefile)
function to easily add secret values to the platform_services_values if secret
configuration is required.
```terraform
provider "kubernetes" {
  # provider configuration ...
}

provider "helm" {
  # provider configuration ...
}

provider "kubectl" {
  # provider configuration ...
}

module "bootstrap" {
  source = "github.com/catalystsquad/terraform-k8s-catalyst-cluster-bootstrap"

  platform_services_values = templatefile("./helm-values/dev-platform-services.yaml", {
    "exampleSecretInput" : var.example_secret
  })

  prometheus_remote_write_username  = var.prometheus_remote_write_username
  prometheus_remote_write_password  = var.prometheus_remote_write_password
  cert_manager_cloudflare_api_token = var.cert_manager_cloudflare_api_token
}
```

### In tandem with [catalyst-platform module](https://github.com/catalystsquad/terraform-aws-catalyst-platform)

If you are using this module alongside the  [catalyst-platform module](https://github.com/catalystsquad/terraform-aws-catalyst-platform)
module, you must configure the Kubernetes providers with dependencies on the
output of the platform module. This module makes use of multiple providers for
deploying kubernetes resources, so configure each with a similar configuration:

```terraform
locals {
  kubernetes_provider_command_args = [
    "eks", "get-token", "--cluster-name", module.platform.eks_cluster_id,
    # Any additional aws provider configuration should be specified via
    # command line args or environment variables, so that the kubernetes
    # provider can retrieve a token via the AWS CLI. This approach requires
    # the AWS CLI to be installed locally.
    "--region", "us-east-1",
    # "--profile", "my-profile-name", 
  ]
}

provider "kubernetes" {
  # overwrite config_path to ensure existing kubeconfig does not get used
  config_path = ""

  # build kube config based on output of platform module to ensure that it
  # speaks to the new cluster when creating the aws-auth configmap
  host                   = module.platform.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.platform.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = local.kubernetes_provider_command_args
  }
}

provider "helm" {
  kubernetes {
    config_path            = ""
    host                   = module.platform.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.platform.eks_cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = local.kubernetes_provider_command_args
    }
  }
}

provider "kubectl" {
  load_config_file       = false
  host                   = module.platform.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.platform.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = local.kubernetes_provider_command_args
  }
}


module "platform" {
  source = "github.com/catalystsquad/terraform-aws-catalyst-platform"

  # other configuration ...
}

module "bootstrap" {
  source = "github.com/catalystsquad/terraform-k8s-catalyst-cluster-bootstrap"
  
  depends_on = [
    module.platform
  ]
  
  # other configuration ...
}

```


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | ~> 1.14.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argo_cd_chart_version"></a> [argo\_cd\_chart\_version](#input\_argo\_cd\_chart\_version) | Version of the argo-cd helm chart to deploy. | `string` | `"3.33.8"` | no |
| <a name="input_argo_cd_values"></a> [argo\_cd\_values](#input\_argo\_cd\_values) | Values of the argo-cd helm chart to deploy. | `list(string)` | `[]` | no |
| <a name="input_cert_manager_cloudflare_api_token"></a> [cert\_manager\_cloudflare\_api\_token](#input\_cert\_manager\_cloudflare\_api\_token) | CloudFlare API token to configure in the Cert Manager CloudFlare API token secret. Disabled if not supplied. | `string` | `""` | no |
| <a name="input_cert_manager_cloudflare_api_token_secret_name"></a> [cert\_manager\_cloudflare\_api\_token\_secret\_name](#input\_cert\_manager\_cloudflare\_api\_token\_secret\_name) | Name of Kubernetes secret to create for managing a Cert Manager CloudFlare API token. | `string` | `"cloudflare-api-token-secret"` | no |
| <a name="input_enable_platform_services"></a> [enable\_platform\_services](#input\_enable\_platform\_services) | Whether to deploy the chart-platform-services ArgoCD application custom resource. | `bool` | `true` | no |
| <a name="input_kube_prometheus_stack_chart_version"></a> [kube\_prometheus\_stack\_chart\_version](#input\_kube\_prometheus\_stack\_chart\_version) | Version of the kube-prometheus-stack helm chart to deploy. | `string` | `"33.1.0"` | no |
| <a name="input_kube_prometheus_stack_values"></a> [kube\_prometheus\_stack\_values](#input\_kube\_prometheus\_stack\_values) | Values of the kube-prometheus-stack helm chart to deploy. | `list(string)` | `[]` | no |
| <a name="input_manage_cert_manager_namespace"></a> [manage\_cert\_manager\_namespace](#input\_manage\_cert\_manager\_namespace) | Enables management of the cert-manager namespace if the cert manager cloudflare api token secret is being managed | `bool` | `true` | no |
| <a name="input_manage_kube_prometheus_stack_namespace"></a> [manage\_kube\_prometheus\_stack\_namespace](#input\_manage\_kube\_prometheus\_stack\_namespace) | Enables management of the kube-prometheus-stack namespace if the remote write secret is being managed | `bool` | `true` | no |
| <a name="input_platform_services_target_revision"></a> [platform\_services\_target\_revision](#input\_platform\_services\_target\_revision) | Target revision of the chart-platform-services ArgoCD application. | `string` | `">=1.0.0-alpha"` | no |
| <a name="input_platform_services_values"></a> [platform\_services\_values](#input\_platform\_services\_values) | Values to pass to the chart-platform-services ArgoCD application. | `string` | `""` | no |
| <a name="input_prometheus_remote_write_password"></a> [prometheus\_remote\_write\_password](#input\_prometheus\_remote\_write\_password) | Basic auth password to configure in the Prometheus remote write secret. Disabled if not supplied. | `string` | `""` | no |
| <a name="input_prometheus_remote_write_secret_name"></a> [prometheus\_remote\_write\_secret\_name](#input\_prometheus\_remote\_write\_secret\_name) | Name of Kubernetes secret to create for managing Prometheus remote write authentication credentials. | `string` | `"prometheus-remote-write-basic-auth"` | no |
| <a name="input_prometheus_remote_write_username"></a> [prometheus\_remote\_write\_username](#input\_prometheus\_remote\_write\_username) | Basic auth username to configure in the Prometheus remote write secret. Disabled if not supplied. | `string` | `""` | no |

## Outputs

No outputs.

## Resources

| Name | Type |
|------|------|
| [helm_release.argo_cd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.kube_prometheus_stack](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace_v1.cert_manager](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.kube_prometheus_stack](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_secret_v1.cert_manager_cloudflare_api_token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.prometheus_remote_write](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_platform_services"></a> [platform\_services](#module\_platform\_services) | github.com/catalystsquad/terraform-k8s-argocd-application | n/a |
<!-- END_TF_DOCS -->
