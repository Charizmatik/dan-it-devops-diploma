data "aws_instances" "worker_nodes" {
  instance_state_names = ["pending", "running"]

  filter {
    name   = "tag:eks:cluster-name"
    values = [aws_eks_cluster.this.name]
  }

  filter {
    name   = "tag:eks:nodegroup-name"
    values = [aws_eks_node_group.this.node_group_name]
  }

  depends_on = [aws_eks_node_group.this]
}

# EKS node group tags are not automatically propagated to its EC2 instances.
# Tag the current node and configure the managed Auto Scaling Group to tag any
# replacement node that it launches in the future.
resource "aws_ec2_tag" "worker_name" {
  count = 1

  resource_id = one(data.aws_instances.worker_nodes.ids)
  key         = "Name"
  value       = "${var.cluster_name}-worker"
}

resource "aws_autoscaling_group_tag" "worker_name" {
  autoscaling_group_name = one(aws_eks_node_group.this.resources[0].autoscaling_groups[*].name)

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-worker"
    propagate_at_launch = true
  }
}

data "aws_ebs_volumes" "worker_root" {
  filter {
    name   = "attachment.instance-id"
    values = [one(data.aws_instances.worker_nodes.ids)]
  }
}

resource "aws_ec2_tag" "worker_root_volume_name" {
  count = 1

  resource_id = one(data.aws_ebs_volumes.worker_root.ids)
  key         = "Name"
  value       = "${var.cluster_name}-worker-root"
}
