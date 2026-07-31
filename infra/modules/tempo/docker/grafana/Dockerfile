# Custom image for the Grafana Tempo POC (infra/modules/tempo).
#
# Grafana's datasource/dashboard provisioning needs files on disk, and
# Grafana's own SQLite state doesn't survive a task restart, so anything
# added via the UI alone wouldn't persist. This bakes in a static datasource
# provisioning file plus the dashboard JSON under dashboards/, both reapplied
# on every container start. There's nothing environment-specific in either
# (Tempo/Prometheus are always reached over localhost, since all three
# containers share the task's network namespace), so unlike the tempo image
# this needs no templating.
#
# See ../../README.md for build/push instructions, and for how dashboard
# live-editing (allowUiUpdates: true in dashboards-provisioning.yaml)
# interacts with this.

ARG GRAFANA_IMAGE_TAG=13.1.1

# checkov:skip=CKV_DOCKER_2:No HEALTHCHECK - ECS/the ALB target group's
# health check (see alb.tf) is what actually governs routing here.
FROM grafana/grafana:${GRAFANA_IMAGE_TAG}

# grafana/grafana already runs as uid 472 ("grafana"); kept explicit (and
# chowning our added files to it, matching the upstream image's own
# provisioning directory ownership) so it doesn't depend on the builder
# inheriting the base image's last USER for an un-chowned COPY.
COPY --chown=472:0 datasources.yaml /etc/grafana/provisioning/datasources/datasources.yaml
COPY --chown=472:0 dashboards-provisioning.yaml /etc/grafana/provisioning/dashboards/forms-tracing-poc.yaml
COPY --chown=472:0 dashboards/ /etc/grafana/dashboards/
USER 472
