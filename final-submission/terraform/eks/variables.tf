variable "aws_region" {
  description = "AWS region in which to create the EKS cluster."
  type        = string
  default     = "eu-central-1"
}

variable "aws_profile" {
  description = "Optional local AWS CLI profile. Leave null when credentials are supplied through environment variables or an IAM role."
  type        = string
  default     = null
  nullable    = true
}

variable "cluster_name" {
  description = "EKS cluster and managed node group name prefix."
  type        = string

  validation {
    condition     = can(regex("^[0-9A-Za-z][A-Za-z0-9_-]{0,39}$", var.cluster_name))
    error_message = "cluster_name must start with a letter or digit, contain only letters, digits, hyphens or underscores, and be at most 40 characters."
  }
}

variable "kubernetes_version" {
  description = "EKS Kubernetes minor version. Version 1.35 is compatible with ingress-nginx chart 4.15.1."
  type        = string
  default     = "1.35"
}

variable "vpc_id" {
  description = "ID of the existing VPC that contains the EKS subnets."
  type        = string

  validation {
    condition     = can(regex("^vpc-[0-9a-f]+$", var.vpc_id))
    error_message = "vpc_id must look like vpc-0123456789abcdef0."
  }
}

variable "subnet_ids" {
  description = "At least two existing subnet IDs in different Availability Zones. Nodes must have outbound internet access."
  type        = list(string)

  validation {
    condition = (
      length(var.subnet_ids) >= 2 &&
      alltrue([for subnet_id in var.subnet_ids : can(regex("^subnet-[0-9a-f]+$", subnet_id))])
    )
    error_message = "subnet_ids must contain at least two valid subnet IDs."
  }
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "IPv4 CIDRs allowed to reach the public Kubernetes API endpoint. Use the administrator workstation public IP with /32."
  type        = list(string)

  validation {
    condition     = length(var.cluster_endpoint_public_access_cidrs) > 0
    error_message = "Provide at least one CIDR allowed to access the Kubernetes API endpoint."
  }
}

variable "node_instance_types" {
  description = "EC2 instance types allowed for the single managed node."
  type        = list(string)
  default     = ["t3.small"]

  validation {
    condition     = length(var.node_instance_types) > 0
    error_message = "Provide at least one EC2 instance type."
  }
}

variable "ingress_nginx_chart_version" {
  description = "Pinned ingress-nginx Helm chart version."
  type        = string
  default     = "4.15.1"
}

variable "argocd_chart_version" {
  description = "Pinned argo-cd Helm chart version."
  type        = string
  default     = "10.4.0"
}

variable "argocd_hostname" {
  description = "Public DNS hostname for the Argo CD UI, for example argocd.mikoladolia.pp.ua."
  type        = string

  validation {
    condition = length(var.argocd_hostname) <= 253 && can(regex(
      "^([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\\.)+[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\\.?$",
      var.argocd_hostname,
    ))
    error_message = "argocd_hostname must be a valid lowercase DNS hostname."
  }
}

variable "argocd_route53_zone_id" {
  description = "Optional Route53 public hosted zone ID. When null, Terraform outputs the CNAME target but does not create DNS."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.argocd_route53_zone_id == null || can(regex("^Z[A-Z0-9]+$", var.argocd_route53_zone_id))
    error_message = "argocd_route53_zone_id must be null or a Route53 hosted zone ID beginning with Z."
  }
}

variable "tags" {
  description = "Tags applied to AWS resources managed by this configuration."
  type        = map(string)
  default = {
    Environment = "diploma"
    ManagedBy   = "Terraform"
  }
}
