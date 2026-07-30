# These repositories hold the custom tempo/grafana images built from
# docker/tempo and docker/grafana, plus a straight mirror of the public
# prom/prometheus image (used for service-graph metrics - see ecs.tf).
# Images are built/mirrored and pushed manually - see README.md - rather
# than through a CI/CD pipeline, as this is a POC. Mirroring prometheus
# rather than pulling it from Docker Hub directly keeps this task fully
# private (no internet egress - see security-groups.tf).

resource "aws_ecr_repository" "tempo" {
  #checkov:skip=CKV_AWS_136:Default AWS-managed encryption is sufficient for this POC
  #checkov:skip=CKV_AWS_51:Tag immutability isn't needed for this POC

  name = "tempo-poc-tempo"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "grafana" {
  #checkov:skip=CKV_AWS_136:Default AWS-managed encryption is sufficient for this POC
  #checkov:skip=CKV_AWS_51:Tag immutability isn't needed for this POC

  name = "tempo-poc-grafana"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "prometheus" {
  #checkov:skip=CKV_AWS_136:Default AWS-managed encryption is sufficient for this POC
  #checkov:skip=CKV_AWS_51:Tag immutability isn't needed for this POC

  name = "tempo-poc-prometheus"

  image_scanning_configuration {
    scan_on_push = true
  }
}
