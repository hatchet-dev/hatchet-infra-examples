data "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_secret" "cloudflare_api_token_secret" {
  metadata {
    name      = "cloudflare-api-token-secret"
    namespace = data.kubernetes_namespace.cert_manager.metadata[0].name
  }

  data = {
    "api-token" = var.cloudflare_api_token_secret
  }
}

resource "kubernetes_manifest" "clusterissuer_letsencrypt_cloudflare_dns" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "letsencrypt-cloudflare-dns"
    }
    "spec" = {
      "acme" = {
        "email" = var.certificate_email
        "privateKeySecretRef" = {
          "name" = "letsencrypt-cloudflare-dns"
        }
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "solvers" = [
          {
            "dns01" = {
              "cloudflare" = {
                "apiTokenSecretRef" = {
                  "key"       = "api-token"
                  "name"      = kubernetes_secret.cloudflare_api_token_secret.metadata[0].name
                  "namespace" = "cert-manager"
                }
              }
            }
          },
        ]
      }
    }
  }
}
