resource "aws_efs_file_system" "prometheus" {
  #checkov:skip=CKV_AWS_184:Default AWS-managed encryption is sufficient for this POC; no requirement for a customer-managed KMS key.
  #checkov:skip=CKV2_AWS_18:No backup plan configured - prometheus's TSDB is disposable, service-graph/span-metrics rebuild from incoming spans, same tradeoff already accepted for the previous localhost-only setup (see README.md).
  encrypted = true

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
}

resource "aws_efs_mount_target" "prometheus" {
  for_each = toset(var.private_subnet_ids)

  file_system_id  = aws_efs_file_system.prometheus.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs_prometheus.id]
}

resource "aws_efs_access_point" "prometheus" {
  file_system_id = aws_efs_file_system.prometheus.id

  # uid/gid 65534 ("nobody") is prom/prometheus's default runtime user.
  posix_user {
    uid = 65534
    gid = 65534
  }

  root_directory {
    path = "/prometheus"

    creation_info {
      owner_uid   = 65534
      owner_gid   = 65534
      permissions = "0755"
    }
  }
}

# Mount targets accept NFS only from the prometheus ECS service's own
# security group - tighter than this module's usual var.vpc_cidr_block-scoped
# ingress convention, and worth it here since nothing else in the VPC has any
# legitimate reason to mount this file system.
resource "aws_security_group" "efs_prometheus" {
  #checkov:skip=CKV2_AWS_5:The security group is attached to the mount targets in this file
  name        = "tempo-${var.env_name}-efs-prometheus"
  description = "NFS ingress for the prometheus EFS mount targets, from the prometheus ECS service only"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "efs_prometheus_ingress_nfs" {
  description              = "permit inbound NFS from the prometheus ECS service security group only"
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.prometheus.id
  security_group_id        = aws_security_group.efs_prometheus.id
}
