# These repositories hold the custom tempo/grafana/mimir/alloy images built
# from docker/tempo, docker/grafana, docker/mimir and docker/alloy. Images
# are built and pushed manually - see README.md - rather than through a
# CI/CD pipeline, as this is a POC. Building our own images (rather than
# pulling upstream ones directly at deploy time) keeps these tasks fully
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

resource "aws_ecr_repository" "mimir" {
  #checkov:skip=CKV_AWS_136:Default AWS-managed encryption is sufficient for this POC
  #checkov:skip=CKV_AWS_51:Tag immutability isn't needed for this POC

  name = "tempo-poc-mimir"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "alloy" {
  #checkov:skip=CKV_AWS_136:Default AWS-managed encryption is sufficient for this POC
  #checkov:skip=CKV_AWS_51:Tag immutability isn't needed for this POC

  name = "tempo-poc-alloy"

  image_scanning_configuration {
    scan_on_push = true
  }
}
