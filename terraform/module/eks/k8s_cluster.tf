


resource "aws_eks_cluster" "eks_cluster" {
    name   = var.cluster_name


    access_config {
        authentication_mode = "API"
    }

    bootstrap_self_managed_addons = false

    role_arn = aws_iam_role.eks_cluster_role.arn
    version = 1.34

    compute_config {
        enabled = true
        node_pools = ["general-purpose"]
        node_role_arn = aws_iam_role.node_role.arn
    }

    kubernetes_network_config {
      elastic_load_balancing {
        enabled = true
      }
      service_ipv4_cidr = "10.116.0.0/20"
    }

    storage_config {
      block_storage {
        enabled = true
      }
    }


    vpc_config {
        subnet_ids = var.subnet_ids
        endpoint_private_access = true
    }



    depends_on = [
        aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
        aws_iam_role_policy_attachment.cluster_AmazonEKSComputePolicy,
        aws_iam_role_policy_attachment.cluster_AmazonEKSBlockStoragePolicy,
        aws_iam_role_policy_attachment.cluster_AmazonEKSLoadBalancingPolicy,
        aws_iam_role_policy_attachment.cluster_AmazonEKSNetworkingPolicy,
    ]
}

resource "aws_iam_role" "eks_cluster_role" {
    name = "${var.cluster_name}-eks-cluster-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "eks.amazonaws.com"
                }
            },
        ]
    })

}

resource "aws_iam_role" "node_role" {
    name = "${var.cluster_name}-eks-node-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            },
        ]
    })
}


resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodeMinimalPolicy" {
    role       = aws_iam_role.node_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy"
  
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryPullOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSComputePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSComputePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSBlockStoragePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSLoadBalancingPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSNetworkingPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}