output "vpc_id" {
  value       = aws_vpc.vpc_eks.id
  description = "VPC id"
  sensitive   = false
}


#
# Outputs
#

# locals {
#   config_map_aws_auth = <<CONFIGMAPAWSAUTH


# apiVersion: v1
# kind: ConfigMap
# metadata:
#   name: aws-auth
#   namespace: kube-system
# data:
#   mapRoles: |
#     - rolearn: ${aws_iam_role.eks_cluster.arn}
#       username: system:node:{{EC2PrivateDNSName}}
#       groups:
#         - system:bootstrappers
#         - system:nodes
# CONFIGMAPAWSAUTH

#   kubeconfig = <<KUBECONFIG


# apiVersion: v1
# clusters:
# - cluster:
#     server: ${aws_eks_cluster.demo.endpoint}
#     certificate-authority-data: ${aws_eks_cluster.demo.certificate_authority[0].data}
#   name: kubernetes
# contexts:
# - context:
#     cluster: kubernetes
#     user: terraform
#   name: terraform
# current-context: aws
# kind: Config
# preferences: {}
# users:
# - name: terraform
#   user:
#     exec:
#       apiVersion: client.authentication.k8s.io/v1alpha1
#       command: aws-iam-authenticator
#       args:
#         - "token"
#         - "-i"
#         - "${var.cluster-name}"
# KUBECONFIG
# }

# output "config_map_aws_auth" {
#   value = local.config_map_aws_auth
# }

# output "kubeconfig" {
#   value = local.kubeconfig
# }