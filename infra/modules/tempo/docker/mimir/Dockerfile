# Custom image for the Grafana Tempo POC (infra/modules/tempo).
#
# Mimir's config file is required for S3 backend/monolithic-ring settings
# that aren't fully settable via CLI flags, and there's nothing
# environment-specific to bake in at build time (bucket name/region are
# runtime env vars), so this reuses the exact same gomplate-as-entrypoint
# approach already built for docker/tempo: gomplate renders mimir.yaml.tmpl
# from the container's actual environment variables at startup, then execs
# mimir - see https://docs.gomplate.ca for the "post-template command
# execution" feature this relies on.
#
# Build (matching the ARM64 Fargate tasks this is deployed to):
#   docker buildx build --platform linux/arm64 -t <repo-url>:latest .
#
# See ../../README.md for full build/push instructions.

ARG MIMIR_IMAGE_TAG=3.1.4
ARG GOMPLATE_VERSION=v5.2.0

FROM alpine:3.22 AS downloader
ARG GOMPLATE_VERSION
ARG TARGETARCH
RUN apk add --no-cache curl
RUN curl -fsSL -o /gomplate \
      "https://github.com/hairyhenderson/gomplate/releases/download/${GOMPLATE_VERSION}/gomplate_linux-${TARGETARCH}" \
    && chmod +x /gomplate
# grafana/mimir's own image has no shell/chown (it's distroless) to create
# a writable data directory for a non-root user - created here instead,
# where full coreutils are available, then COPY --chown'd into the final
# stage below (explicit --chown, not relying on inheriting this stage's
# ownership implicitly).
RUN mkdir -p /data

# checkov:skip=CKV_DOCKER_2:No HEALTHCHECK - ECS/the ALB target group's
# health check (see alb.tf) is what actually governs routing here.
FROM grafana/mimir:${MIMIR_IMAGE_TAG}

# grafana/mimir runs as root by default and has no shell/chown of its own
# to create a writable data directory for a non-root user - /data is
# created in the downloader stage instead (see above) and COPY --chown'd
# in here. Several of mimir's components (ruler, activity tracker, ...)
# default to relative paths under the working directory, so WORKDIR is set
# to /data too - lets all of them land somewhere writable without setting
# each one explicitly in the config.
COPY --from=downloader --chown=10001:10001 /gomplate /gomplate
COPY --from=downloader --chown=10001:10001 /data /data
COPY --chown=10001:10001 mimir.yaml.tmpl /etc/mimir.yaml.tmpl
WORKDIR /data
USER 10001:10001

ENTRYPOINT ["/gomplate", "-f", "/etc/mimir.yaml.tmpl", "-o", "/tmp/mimir.yaml", "--", "/bin/mimir", "-config.file=/tmp/mimir.yaml"]
