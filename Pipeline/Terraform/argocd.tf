terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
  }
}
provider "kubernetes" {
  config_path = "~/.kube/config"  # Update this path if your kubeconfig is located elsewhere
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"  # Update this path if your kubeconfig is located elsewhere
  }
}

resource "kubernetes_namespace" "example" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.6.6"  # You can update this to the latest version
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  
  values = [
    "${file("values.yaml")}"
  ]

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "server.extraArgs"
    value = "{--insecure}"
  }
  
  set {
    name  = "cluster.enabled"
    value = "true"
  }

  set {
    name  = "metrics.enabled"
    value = "true"
  }

  set {
    name  = "service.annotations.prometheus\\.io/port"
    value = "9127"
    type  = "string"
  }
}

output "argocd_server_service" {
  value = kubernetes_namespace.argocd.metadata[0].name
  description = "The namespace where ArgoCD is installed"
}
