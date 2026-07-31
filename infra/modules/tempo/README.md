# tempo

A throwaway proof-of-concept deployment of Grafana Tempo + Grafana on ECS
Fargate, used to evaluate Tempo as an alternative to X-Ray for application
tracing. Deployed only via `infra/deployments/forms/tempo`, dev environment
only. Not intended to be productionised as-is.

This module does not build or push its own images through a pipeline - the
two custom images (`docker/tempo`, `docker/grafana`), plus a straight mirror
of the public `prom/prometheus` image (used for service-graph metrics), are
built/mirrored and pushed by hand. This is deliberate: it's a POC, and
setting up a CodeBuild/CodePipeline for it isn't worth the extra
infrastructure.

## One-time setup

Run these once, before the first `make dev forms/tempo apply` succeeds
(the ECS service will exist but its tasks won't start until the images
below have been pushed).

### 1. Apply the module once to create the ECR repositories

```
gds aws forms-dev-admin --shell
make dev forms/tempo apply
```

(the ECS service's tasks will fail to pull an image until step 2 - that's
expected).

### 2. Build/mirror and push all three images

Requires Docker with `buildx` and to be authenticated to ECR in the dev
account (`aws ecr get-login-password ...`, shown below).

```
ACCOUNT_ID=<dev account id>
REGION=eu-west-2
aws ecr get-login-password --region "${REGION}" \
  | docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

docker buildx build --platform linux/arm64 \
  -t "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/tempo-poc-tempo:latest" \
  --push \
  docker/tempo

docker buildx build --platform linux/arm64 \
  -t "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/tempo-poc-grafana:latest" \
  --push \
  docker/grafana
```

Prometheus needs no Dockerfile - the stock image is used unmodified (its
config comes entirely from the `command` override in `ecs.tf`), so it's
just pulled, tagged and pushed as-is, matching the arm64 Fargate tasks:

```
docker pull --platform linux/arm64 prom/prometheus:latest
docker tag prom/prometheus:latest "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/tempo-poc-prometheus:latest"
docker push "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/tempo-poc-prometheus:latest"
```

Re-run the relevant part of this whenever `docker/tempo` or `docker/grafana`
change (e.g. a new Tempo/Grafana version, a config template change), or
periodically to pick up newer prometheus/prom images. Bucket name/region are
supplied at runtime via ECS environment variables (see `ecs.tf`), so
day-to-day config values don't require a rebuild.

After pushing, force a new deployment so the running task picks up the new
image (the task definitions reference `<repo_url>:latest` by default - see
`var.image_tag` in `variables.tf`):

```
aws ecs update-service --cluster <cluster> --service tempo-dev --force-new-deployment
```

### 3. Create the Grafana basic auth credentials

Grafana is public (behind CloudFront) with anonymous access disabled, so it
needs a username/password. These are read from SSM by the ECS task execution
role - create them once, matching the pattern used for forms-admin's basic
auth (see `infra/modules/forms-admin/main.tf`):

```
aws ssm put-parameter --name /tempo-dev/basic-auth/username --type SecureString --value <username>
aws ssm put-parameter --name /tempo-dev/basic-auth/password --type SecureString --value <password>
```

## Architecture notes

- Tempo + Grafana + Prometheus run as three containers in a single ECS task
  (`ecs.tf`), sharing the task's network namespace - Grafana reaches Tempo
  over `localhost:3200`, and Tempo's metrics-generator writes to Prometheus
  over `localhost:9090`.
- Trace storage is S3 (`s3.tf`, via the `secure-bucket` module), so traces
  survive task restarts, unlike the upstream docker-compose example's local
  disk. The Tempo task role has the minimal IAM permissions Tempo's docs
  recommend; no static credentials are used - Tempo picks up the task role
  via the default AWS SDK credential chain.
- Service-graph/span-metrics are derived by Tempo's `metrics_generator` and
  written to the Prometheus container (`docker/tempo/tempo.yaml.tmpl`),
  which Grafana's Tempo datasource links to via `serviceMap.datasourceUid`
  (`docker/grafana/datasources.yaml`). Unlike traces, these metrics are not
  S3-backed - losing them on a task restart just means the graph rebuilds
  itself as new spans arrive, which is an acceptable tradeoff for a POC.
- Grafana's UI is exposed publicly via the existing CloudFront distribution
  and public ALB (`alb.tf`), behind basic auth. OTLP trace ingestion
  (`tempo-otlp.internal.<root_domain>`) is internal-ALB-only, using OTLP/HTTP
  (port 4318) rather than gRPC so it can use the existing plain-HTTP internal
  listener, the same as every other internal app-to-app route in this repo -
  a gRPC target group would need the internal HTTPS listener plus SNI
  certificate coverage, which isn't worth it here.
- This task has no internet egress (see `security-groups.tf`), so all three
  images are pulled from our own ECR rather than Docker Hub directly - see
  the one-time setup above. This is also why several Grafana update-check /
  telemetry background jobs are explicitly disabled in `ecs.tf` (they'd
  otherwise just time out repeatedly against grafana.com).
- `docker/grafana/datasources.yaml` pins the Tempo datasource to `uid: tempo`
  (matching Prometheus's `uid: prometheus`) rather than letting Grafana
  auto-generate one, so dashboard JSON can reference a stable datasource uid
  instead of an opaque generated string. **This is an image-level change** -
  it only takes effect after the Grafana image is rebuilt, pushed, and the
  ECS service redeployed (see one-time setup above); it won't apply to an
  already-running task. The currently-live instance was provisioned before
  this change, so its Tempo datasource still has an auto-generated uid - the
  dashboard JSON files below already reference `tempo`, so after redeploying,
  check (`list_datasources`/the Grafana UI) whether Grafana updated the
  existing "Tempo" datasource in place or left the old one orphaned
  alongside a new one; delete the orphan and re-push the dashboards if so.
- `docker/grafana/dashboards/*.json` are provisioned from file (like
  `datasources.yaml`), via `docker/grafana/dashboards-provisioning.yaml`
  (`COPY`'d to `/etc/grafana/provisioning/dashboards/forms-tracing-poc.yaml`)
  pointing at `/etc/grafana/dashboards`, which the whole `dashboards/`
  directory is `COPY`'d into. This is why the dashboards needed baking into
  the image at all: Grafana's own state (`grafana.db`) is on the same
  ephemeral container filesystem as everything else here and does **not**
  survive a task restart, so dashboards created only through the API/UI
  would otherwise be lost just like the Prometheus data above. The provider
  targets the existing `forms-tracing-poc` folder by uid, and each JSON's own
  `uid` matches what's already live, so redeploying updates these dashboards
  in place rather than duplicating them.
  - `allowUiUpdates: true` for now, since the dashboard set is still being
    iterated on - you can still tweak panels live in Grafana, but those edits
    only last until the next reconcile/restart, which resets to whatever's
    committed here. Re-export (`get_dashboard_by_uid`) and commit anything
    worth keeping. Switch to `false` once the set stabilises, or before any
    production use, to make the committed JSON the sole source of truth.
