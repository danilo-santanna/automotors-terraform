output "vpc_id"               { value = module.vpc.vpc_id }
output "private_subnets"      { value = module.vpc.private_subnets }
output "cluster_name"         { value = module.eks.cluster_name }
output "cluster_endpoint"     { value = module.eks.cluster_endpoint }
output "cluster_oidc_issuer"  { value = module.eks.cluster_oidc_issuer_url }
output "node_sg_id"           { value = module.eks.node_security_group_id }
