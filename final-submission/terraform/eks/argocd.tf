locals {
  argocd_resources = {
    controller = {
      requests = { cpu = "100m", memory = "256Mi" }
      limits   = { cpu = "500m", memory = "512Mi" }
    }
    server = {
      requests = { cpu = "50m", memory = "128Mi" }
      limits   = { cpu = "300m", memory = "256Mi" }
    }
    repo_server = {
      requests = { cpu = "50m", memory = "128Mi" }
      limits   = { cpu = "500m", memory = "512Mi" }
    }
    redis = {
      requests = { cpu = "25m", memory = "64Mi" }
      limits   = { cpu = "200m", memory = "128Mi" }
    }
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version
  namespace        = "argocd"
  create_namespace = true

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  wait_for_jobs   = true
  timeout         = 900

  values = [yamlencode({
    global = {
      domain = var.argocd_hostname
    }

    # This diploma cluster has one t3.small node. Keep only the components
    # required for a single-cluster, local-admin GitOps demonstration.
    dex = {
      enabled = false
    }
    notifications = {
      enabled = false
    }
    applicationSet = {
      replicas = 0
    }

    crds = {
      keep = false
    }

    configs = {
      params = {
        "server.insecure" = true
      }
    }

    controller = {
      resources = local.argocd_resources.controller
    }
    repoServer = {
      resources = local.argocd_resources.repo_server
    }
    redis = {
      resources = local.argocd_resources.redis
    }
    server = {
      resources = local.argocd_resources.server
      ingress = {
        enabled          = true
        ingressClassName = "nginx"
        hostname         = var.argocd_hostname
        path             = "/"
        pathType         = "Prefix"
        tls              = false
      }
    }
  })]

  depends_on = [helm_release.ingress_nginx]
}

# ingress-nginx owns the public NLB. Every application Ingress, including
# Argo CD, uses the same NLB and is selected by its Host header.
data "kubernetes_service_v1" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }

  depends_on = [helm_release.ingress_nginx]
}

resource "aws_route53_record" "argocd" {
  count = var.argocd_route53_zone_id == null ? 0 : 1

  zone_id = var.argocd_route53_zone_id
  name    = var.argocd_hostname
  type    = "CNAME"
  ttl     = 300
  records = [data.kubernetes_service_v1.ingress_nginx.status[0].load_balancer[0].ingress[0].hostname]

  depends_on = [helm_release.argocd]
}
