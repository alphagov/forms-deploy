# Custom image for the Grafana Tempo POC (infra/modules/tempo).
#
# Grafana's datasource provisioning needs a file on disk, and Grafana's own
# SQLite state doesn't survive a task restart, so a datasource added via the
# UI wouldn't persist. This bakes a static datasource provisioning file in
# instead, which is reapplied on every container start. There's nothing
# environment-specific in it (Tempo is always reached over localhost, since
# both containers share the task's network namespace), so unlike the tempo
# image this needs no templating.
#
# See ../../README.md for build/push instructions.

ARG GRAFANA_IMAGE_TAG=13.1.1

# checkov:skip=CKV_DOCKER_2:No HEALTHCHECK - ECS/the ALB target group's
# health check (see alb.tf) is what actually governs routing here.
FROM grafana/grafana:${GRAFANA_IMAGE_TAG}

# grafana/grafana already runs as uid 472 ("grafana"); kept explicit (and
# chowning our added file to it, matching the upstream image's own
# provisioning directory ownership) so it doesn't depend on the builder
# inheriting the base image's last USER for an un-chowned COPY.
COPY --chown=472:0 datasources.yaml /etc/grafana/provisioning/datasources/datasources.yaml
USER 472
