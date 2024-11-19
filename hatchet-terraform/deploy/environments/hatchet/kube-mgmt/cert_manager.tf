# data "google_secret_manager_secret_version" "cloudflare_token" {
#   project = var.project
#   secret  = "hatchet-cert-manager-cloudflare-token"
# }

# resource "kubernetes_namespace" "cert_manager" {
#   metadata {
#     name = "cert-manager"
#   }
# }


# resource "helm_release" "cert-manager" {
#   name       = "cert-manager"
#   namespace  = kubernetes_namespace.cert_manager.metadata[0].name
#   repository = "https://charts.jetstack.io"
#   chart      = "cert-manager"
#   version    = "v1.5.5"

#   set {
#     name  = "installCRDs"
#     value = "false"
#   }

#   # run cert-manager chart on "system" nodes
#   values = [
#     <<VALUES
# nodeSelector:
#   porter.run/workload-kind: "system"
# tolerations:
# - key: "porter.run/workload-kind"
#   operator: "Equal"
#   value: "system"
#   effect: "NoSchedule"
# webhook:
#   nodeSelector:
#     porter.run/workload-kind: "system"
#   tolerations:
#   - key: "porter.run/workload-kind"
#     operator: "Equal"
#     value: "system"
#     effect: "NoSchedule"
# cainjector:
#   nodeSelector:
#     porter.run/workload-kind: "system"
#   tolerations:
#   - key: "porter.run/workload-kind"
#     operator: "Equal"
#     value: "system"
#     effect: "NoSchedule"
# VALUES
#   ]
# }

# resource "kubernetes_secret" "cloudflare_api_token_secret" {
#   depends_on = [
#     data.google_secret_manager_secret_version.cloudflare_token
#   ]

#   metadata {
#     name      = "cloudflare-api-token-secret"
#     namespace = kubernetes_namespace.cert_manager.metadata[0].name
#   }

#   data = {
#     "api-token" = data.google_secret_manager_secret_version.cloudflare_token.secret_data
#   }
# }

# resource "kubernetes_manifest" "clusterissuer_letsencrypt_cloudflare_dns" {
#   depends_on = [
#     helm_release.cert-manager
#   ]

#   manifest = {
#     "apiVersion" = "cert-manager.io/v1"
#     "kind"       = "ClusterIssuer"
#     "metadata" = {
#       "name" = "letsencrypt-cloudflare-dns"
#     }
#     "spec" = {
#       "acme" = {
#         "email" = "alexander@hatchet.run"
#         "privateKeySecretRef" = {
#           "name" = "letsencrypt-cloudflare-dns"
#         }
#         "server" = "https://acme-v02.api.letsencrypt.org/directory"
#         "solvers" = [
#           {
#             "dns01" = {
#               "cloudflare" = {
#                 "apiTokenSecretRef" = {
#                   "key"       = "api-token"
#                   "name"      = "cloudflare-api-token-secret"
#                   "namespace" = "cert-manager"
#                 }
#               }
#             }
#           },
#         ]
#       }
#     }
#   }
# }
