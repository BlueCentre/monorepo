# Configure the Kubernetes provider to connect to your Colima cluster.
# Colima typically exposes the Kubernetes context as "colima".
provider "kubernetes" {
  # https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs
  config_path    = "~/.kube/config"       # This is the standard location; adjust if necessary
  config_context = var.kubernetes_context # If needed; Colima usually sets the current context
}

provider "helm" {
  # https://registry.terraform.io/providers/hashicorp/helm/2.17.0/docs
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = var.kubernetes_context
  }
}

provider "kustomization" {
  # https://registry.terraform.io/providers/kbst/kustomization/latest/docs
  kubeconfig_path = "~/.kube/config"
  context         = var.kubernetes_context
}

provider "kubectl" {
  # https://registry.terraform.io/providers/alekc/kubectl/latest/docs
  config_path    = "~/.kube/config"       # This is the standard location; adjust if necessary
  config_context = var.kubernetes_context # If needed; Colima usually sets the current context
}


# Example: Create the namespace if it doesn't already exist
# resource "kubernetes_namespace" "ingress_nginx" {
#   metadata {
#     name = "ingress-nginx"
#   }
# }

# Example: Install the Nginx Ingress Controller Helm chart
# resource "helm_release" "nginx_ingress" {
#   name       = "nginx-ingress"
#   repository = "https://kubernetes.github.io/ingress-nginx"
#   chart      = "ingress-nginx"
#   namespace  = "ingress-nginx" # Create this namespace if it doesn't exist

#   set {
#     name  = "controller.service.loadBalancerIP" # For local testing, keep commented out or set to null
#     value = null                                # Let the service type LoadBalancer assign it or use NodePort
#   }

#   set {
#     name  = "controller.service.type"
#     value = "NodePort" # Use NodePort for local Colima. LoadBalancer requires a cloud provider.
#   }

#   #  values = [
#   #    file("${path.module}/values.yaml") # Optional: Load values from a YAML file
#   #  ]
# }


# Output the Nginx Ingress Controller's IP (if applicable and available)
# output "nginx_ingress_ip" {
#   value = helm_release.nginx_ingress.status.load_balancer.ingress[0].ip
# }
