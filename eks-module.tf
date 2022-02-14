locals {
  name            = "ex-${replace(basename(path.cwd), "_", "-")}"
}
 
 
 module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "18.5.1"

  cluster_name                    = "my-cluster"
  cluster_version                 = "1.21"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  # cluster_encryption_config = [{
  #   provider_key_arn = "ac01234b-00d9-40f6-ac95-e42345f78b00"
  #   resources        = ["secrets"]
  # }]

  vpc_id     = aws_vpc.vpc_eks.id
  subnet_ids = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id,
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]


  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  # # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    disk_size              = 50
    instance_types         = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
    vpc_security_group_ids = [aws_security_group.additional.id]
  }

  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"
      labels = {
        Environment = "test"
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
      }
      taints = {
        dedicated = {
          key    = "dedicated"
          value  = "gpuGroup"
          effect = "NO_SCHEDULE"
        }
      }
      tags = {
        ExtraTag = "example"
      }
    }
  }

  # Fargate Profile(s)
  # fargate_profiles = {
  #   default = {
  #     name = "default"
  #     selectors = [
  #       {
  #         namespace = "kube-system"
  #         labels = {
  #           k8s-app = "kube-dns"
  #         }
  #       },
  #       {
  #         namespace = "default"
  #       }
  #     ]

  #     tags = {
  #       Owner = "test"
  #     }

  #     timeouts = {
  #       create = "20m"
  #       delete = "20m"
  #     }
  #   }
  # }

  tags = {
    Name = "yboreyko-eks"
    Terraform   = "true"
  }
}

 
resource "aws_security_group" "additional" {
  name_prefix = "${local.name}-additional"
  vpc_id      = aws_vpc.vpc_eks.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }

  # tags = local.tags
}

resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  # tags = local.tags
}
 
 
 
 





#   eks_managed_node_group_defaults = {
#     ami_type               = "AL2_x86_64"
#     disk_size              = 50
#     instance_types         = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
#   }

# eks_managed_node_groups = {
#   # Uses defaults provided by module with the default settings above overriding the module defaults
#   default = {}

#   # This further overrides the instance types used
#   compute = {
#     instance_types = ["c5.large", "c6i.large", "c6d.large"]
#   }

#   # This further overrides the instance types and disk size used
#   persistent = {
#     disk_size      = 1024
#     instance_types = ["r5.xlarge", "r6i.xlarge", "r5b.xlarge"]
#   }

#   # This overrides the OS used
#   bottlerocket = {
#     ami_type = "BOTTLEROCKET_x86_64"
#     platform = "bottlerocket"
#   }
# }