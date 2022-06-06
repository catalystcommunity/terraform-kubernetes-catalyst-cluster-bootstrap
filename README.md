# terraform-k8s-catalyst-cluster-bootstrap

The module provisions Kubernetes resources for "bootstrapping" a Kubernetes
cluster. The bootstrap process installs open source tools for operating and
monitoring Kubernetes, including the following:

* [Argo CD](https://argo-cd.readthedocs.io/en/stable/)
* [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack), deployed outside of the chart-platform-services helm chart to allow for Prometheus custom resources to be deployed successfully if enabled in the ArgoCD helm chart.
* [chart-platform-services](https://github.com/catalystsquad/chart-platform-services) from Catalyst Squad, which includes various other open-source tools deployed via an [ArgoCD app of apps pattern](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/#app-of-apps-pattern).
* External dependencies for software contained in chart-platform-services including resources such as secrets which are not managed by the helm charts implemented in the charts.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argo_cd_chart_version"></a> [argo\_cd\_chart\_version](#input\_argo\_cd\_chart\_version) | n/a | `string` | `"3.33.8"` | no |
| <a name="input_argo_cd_values"></a> [argo\_cd\_values](#input\_argo\_cd\_values) | n/a | `list(string)` | `[]` | no |
| <a name="input_cert_manager_cloudflare_api_token"></a> [cert\_manager\_cloudflare\_api\_token](#input\_cert\_manager\_cloudflare\_api\_token) | n/a | `string` | `""` | no |
| <a name="input_cert_manager_cloudflare_api_token_secret_name"></a> [cert\_manager\_cloudflare\_api\_token\_secret\_name](#input\_cert\_manager\_cloudflare\_api\_token\_secret\_name) | n/a | `string` | `"cloudflare-api-token-secret"` | no |
| <a name="input_enable_platform_services"></a> [enable\_platform\_services](#input\_enable\_platform\_services) | n/a | `bool` | `false` | no |
| <a name="input_kube_prometheus_stack_chart_version"></a> [kube\_prometheus\_stack\_chart\_version](#input\_kube\_prometheus\_stack\_chart\_version) | n/a | `string` | `"33.1.0"` | no |
| <a name="input_kube_prometheus_stack_values"></a> [kube\_prometheus\_stack\_values](#input\_kube\_prometheus\_stack\_values) | n/a | `list(string)` | `[]` | no |
| <a name="input_manage_cert_manager_namespace"></a> [manage\_cert\_manager\_namespace](#input\_manage\_cert\_manager\_namespace) | Enables management of the cert-manager namespace if the cert manager cloudflare api token secret is being managed | `bool` | `true` | no |
| <a name="input_manage_kube_prometheus_stack_namespace"></a> [manage\_kube\_prometheus\_stack\_namespace](#input\_manage\_kube\_prometheus\_stack\_namespace) | Enables management of the kube-prometheus-stack namespace if the remote write secret is being managed | `bool` | `true` | no |
| <a name="input_platform_services_target_revision"></a> [platform\_services\_target\_revision](#input\_platform\_services\_target\_revision) | n/a | `string` | `">=1.0.0-alpha"` | no |
| <a name="input_platform_services_values"></a> [platform\_services\_values](#input\_platform\_services\_values) | n/a | `string` | `""` | no |
| <a name="input_prometheus_remote_write_password"></a> [prometheus\_remote\_write\_password](#input\_prometheus\_remote\_write\_password) | n/a | `string` | `""` | no |
| <a name="input_prometheus_remote_write_secret_name"></a> [prometheus\_remote\_write\_secret\_name](#input\_prometheus\_remote\_write\_secret\_name) | n/a | `string` | `"prometheus-remote-write-basic-auth"` | no |
| <a name="input_prometheus_remote_write_username"></a> [prometheus\_remote\_write\_username](#input\_prometheus\_remote\_write\_username) | n/a | `string` | `""` | no |

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
