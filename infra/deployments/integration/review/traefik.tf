module "traefik" {
  source = "./traefik"

  ecs_clusters_to_scan = [aws_ecs_cluster.review.name]
  ecs_cluster_arn      = aws_ecs_cluster.review.id
  vpc_id               = module.vpc.vpc_id
  alb_tls_listener_arn = module.alb.alb_tls_listener_arn
  subnet_ids           = module.vpc.private_subnet_ids
  cidr_block           = module.vpc.vpc_cidr_block
}
