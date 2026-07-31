# Custom image for the Grafana Tempo POC (infra/modules/tempo).
#
# Unlike tempo/mimir, this needs no gomplate/templating machinery: Alloy's
# own config language has first-class environment variable support
# (sys.env("VAR"), used directly in config.alloy), and the upstream
# grafana/alloy image is Ubuntu-based with a real shell and a pre-built
# non-root user (uid/gid 473, with /var/lib/alloy already owned by it) -
# no distroless permission-wrangling needed either.
#
# Build (matching the ARM64 Fargate tasks this is deployed to):
#   docker buildx build --platform linux/arm64 -t <repo-url>:latest .
#
# See ../../README.md for full build/push instructions.

ARG ALLOY_IMAGE_TAG=v1.18.0

# checkov:skip=CKV_DOCKER_2:No HEALTHCHECK - ECS/the ALB target group's
# health check (see alb.tf) is what actually governs routing here.
FROM grafana/alloy:${ALLOY_IMAGE_TAG}

COPY --chown=473:473 config.alloy /etc/alloy/config.alloy
USER 473:473

ENTRYPOINT ["/bin/alloy", "run", "--server.http.listen-addr=0.0.0.0:12345", "--storage.path=/var/lib/alloy/data", "/etc/alloy/config.alloy"]
