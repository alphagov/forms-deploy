# These repositories hold the custom tempo/grafana images built from
# docker/tempo and docker/grafana. Images are built and pushed manually -
# see README.md - rather than through a CI/CD pipeline, as this is a POC.

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
