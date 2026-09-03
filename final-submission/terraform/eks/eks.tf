data "aws_subnet" "selected" {
  for_each = toset(var.subnet_ids)
  id       = each.value
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version

  tags = {
    Name = var.cluster_name
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }

  lifecycle {
    precondition {
      condition = alltrue([
        for subnet in data.aws_subnet.selected : subnet.vpc_id == var.vpc_id
      ])
      error_message = "Every subnet in subnet_ids must belong to vpc_id."
    }

    precondition {
      condition = length(distinct([
        for subnet in data.aws_subnet.selected : subnet.availability_zone
      ])) >= 2
      error_message = "subnet_ids must span at least two Availability Zones."
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
  ]
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-workers"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = var.subnet_ids
  version         = var.kubernetes_version

  ami_type       = "AL2023_x86_64_STANDARD"
  capacity_type  = "ON_DEMAND"
  disk_size      = 20
  instance_types = var.node_instance_types

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    workload = "diploma"
  }

  tags = {
    Name = "${var.cluster_name}-workers"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_worker,
    aws_iam_role_policy_attachment.eks_node_cni,
    aws_iam_role_policy_attachment.eks_node_ecr,
  ]
}
