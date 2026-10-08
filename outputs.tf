output "vpc_id" {
  description = "MediCare VPC ID"
  value       = aws_vpc.medicare.id
}

output "eks_cluster_name" {
  description = "MediCare EKS cluster name"
  value       = aws_eks_cluster.medicare.name
}

output "eks_cluster_endpoint" {
  description = "MediCare EKS cluster API endpoint"
  value       = aws_eks_cluster.medicare.endpoint
}

output "eks_cluster_arn" {
  description = "MediCare EKS cluster ARN"
  value       = aws_eks_cluster.medicare.arn
}

output "eks_node_group_name" {
  description = "MediCare EKS node group name"
  value       = aws_eks_node_group.medicare.node_group_name
}