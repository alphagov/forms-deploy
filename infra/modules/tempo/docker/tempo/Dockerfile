# Custom image for the Grafana Tempo POC (infra/modules/tempo).
#
# The upstream grafana/tempo image is distroless (no shell), and Tempo's
# OTLP receiver / S3 storage config isn't fully settable via CLI flags, so a
# real config file is required. Rather than baking environment-specific
# values (S3 bucket name, region) into the image at build time, this image
# bundles a static gomplate binary as its entrypoint: gomplate renders
# tempo.yaml.tmpl from the container's actual environment variables at
# startup, then execs tempo - see https://docs.gomplate.ca for the
# "post-template command execution" feature this relies on. No shell is
# needed anywhere, so this still works on top of the distroless base.
#
# Build (matching the ARM64 Fargate tasks this is deployed to):
#   docker buildx build --platform linux/arm64 -t <repo-url>:tempo .
#
# See ../../README.md for full build/push instructions.

ARG TEMPO_IMAGE_TAG=3.0.2
ARG GOMPLATE_VERSION=v5.2.0

FROM alpine:3.22 AS downloader
ARG GOMPLATE_VERSION
ARG TARGETARCH
RUN apk add --no-cache curl
RUN curl -fsSL -o /gomplate \
      "https://github.com/hairyhenderson/gomplate/releases/download/${GOMPLATE_VERSION}/gomplate_linux-${TARGETARCH}" \
    && chmod +x /gomplate

# checkov:skip=CKV_DOCKER_2:No HEALTHCHECK - the distroless base has no
# shell/probe binary to run one, and ECS/the ALB target group's health
# check (see alb.tf) is what actually governs routing here anyway.
FROM grafana/tempo:${TEMPO_IMAGE_TAG}

# grafana/tempo already runs as this non-root user; kept explicit (and
# chowning our added files to it) so it doesn't depend on the builder
# inheriting the base image's last USER for un-chowned COPYs.
COPY --from=downloader --chown=10001:10001 /gomplate /gomplate
COPY --chown=10001:10001 tempo.yaml.tmpl /etc/tempo.yaml.tmpl
USER 10001:10001

ENTRYPOINT ["/gomplate", "-f", "/etc/tempo.yaml.tmpl", "-o", "/tmp/tempo.yaml", "--", "/tempo", "-config.file=/tmp/tempo.yaml"]
