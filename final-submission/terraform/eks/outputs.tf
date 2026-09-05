output "cluster_name" {
  description = "Created EKS cluster name."
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "EKS Kubernetes API endpoint."
  value       = aws_eks_cluster.this.endpoint
}

output "node_group_name" {
  description = "Managed node group name."
  value       = aws_eks_node_group.this.node_group_name
}

output "configure_kubectl_command" {
  description = "Command that adds this cluster to the local kubeconfig."
  value = join(" ", compact([
    "aws eks update-kubeconfig",
    "--region ${var.aws_region}",
    var.aws_profile == null ? null : "--profile ${var.aws_profile}",
    "--name ${aws_eks_cluster.this.name}",
  ]))
}

output "verification_commands" {
  description = "Commands for verifying the single node, ingress-nginx and Argo CD installation."
  value = [
    "kubectl get nodes -o wide",
    "kubectl get pods -n ingress-nginx -o wide",
    "kubectl get service -n ingress-nginx ingress-nginx-controller",
    "kubectl get pods,service,ingress -n argocd",
  ]
}

output "argocd_url" {
  description = "Public Argo CD UI URL. It becomes reachable after its DNS record resolves."
  value       = "http://${var.argocd_hostname}"
}

output "argocd_dns_target" {
  description = "Create a CNAME from argocd_hostname to this ingress-nginx NLB hostname when Route53 is managed externally."
  value       = data.kubernetes_service_v1.ingress_nginx.status[0].load_balancer[0].ingress[0].hostname
}

output "argocd_dns_managed_by_terraform" {
  description = "Whether this configuration creates the Argo CD Route53 record."
  value       = var.argocd_route53_zone_id != null
}
