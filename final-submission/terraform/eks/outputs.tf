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
  description = "Commands for verifying the single node and ingress-nginx installation."
  value = [
    "kubectl get nodes -o wide",
    "kubectl get pods -n ingress-nginx -o wide",
    "kubectl get service -n ingress-nginx ingress-nginx-controller",
  ]
}
