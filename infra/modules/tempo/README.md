# tempo

A throwaway proof-of-concept deployment of Grafana Tempo + Grafana + Mimir +
Alloy on ECS Fargate, used to evaluate Tempo as an alternative to X-Ray for
application tracing. Deployed only via `infra/deployments/forms/tempo`, dev
environment only. Not intended to be productionised as-is.

This module does not build or push its own images through a pipeline - the
four custom images (`docker/tempo`, `docker/grafana`, `docker/mimir`,
`docker/alloy`) are built and pushed by hand (`build-and-push.sh <image>`).
This is deliberate: it's a POC, and setting up a CodeBuild/CodePipeline for
it isn't worth the extra infrastructure.

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

### 2. Build and push all four images

Requires Docker with `buildx` and to be authenticated to ECR in the dev
account. `build-and-push.sh` handles both:

```
./build-and-push.sh tempo
./build-and-push.sh grafana
./build-and-push.sh mimir
./build-and-push.sh alloy
```

Re-run the relevant one whenever that image's `docker/<name>` directory
changes (e.g. a new upstream version, a config template change). Bucket
name/region are supplied at runtime via ECS environment variables (see
`ecs.tf`/`mimir.tf`), so day-to-day config values don't require a rebuild.

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

- Tempo + Grafana run as two containers in a single ECS task (`ecs.tf`),
  sharing the task's network namespace - Grafana reaches Tempo over
  `localhost:3200`. Mimir runs as its own ECS service (`mimir.tf`), reached
  by both over the internal ALB at `http://mimir.internal.<root_domain>`
  rather than `localhost`.
- Trace storage is S3 (`s3.tf`, via the `secure-bucket` module), so traces
  survive task restarts, unlike the upstream docker-compose example's local
  disk. The Tempo task role has the minimal IAM permissions Tempo's docs
  recommend; no static credentials are used - Tempo picks up the task role
  via the default AWS SDK credential chain.
- Service-graph/span-metrics are derived by Tempo's `metrics_generator` and
  written to Mimir (`docker/tempo/tempo.yaml.tmpl`), which Grafana's Tempo
  datasource links to via `serviceMap.datasourceUid`
  (`docker/grafana/datasources.yaml`). Mimir stores its blocks in S3 (`s3.tf`,
  same `secure-bucket`/IAM-role-auth pattern as Tempo's own trace bucket) -
  **but Mimir's write path is `Distributor → Ingester (in-memory + local
  WAL) → S3 (periodic block flush)`, not a direct stream to S3.** The
  ingester cuts a new TSDB block every 2 hours (`tsdb.block-ranges-period`'s
  default) and only ships a block to S3 once that window closes - so at any
  moment, up to ~2h of the most recent data lives only in the active
  in-memory+local-WAL block (on the container's own ephemeral disk - there's
  deliberately no persistent volume here) and would be lost in a restart.
  Everything from earlier windows is already durably in S3 - a real
  improvement over the plain-Prometheus setup this replaced, which lost
  everything on every restart.
- Mimir is deployed with no rolling overlap
  (`deployment_maximum_percent = 100`, `deployment_minimum_healthy_percent =
  0`) and explicit `availability_zone_rebalancing = "DISABLED"` (`mimir.tf`).
  Nothing is actually shared-mounted anymore (no EFS), so this is more
  conservative than strictly necessary - kept simple for this first pass
  rather than stacking a deployment-strategy change on top of the
  storage-engine swap; a normal rolling deployment (this repo's usual
  200/100 convention) is likely fine once this is proven stable.
- Grafana's UI is exposed publicly via the existing CloudFront distribution
  and public ALB (`alb.tf`), behind basic auth. OTLP trace ingestion
  (`alloy-otlp.internal.<root_domain>`, `tempo-otlp.internal.<root_domain>`),
  Mimir access (`mimir.internal.<root_domain>`), and Tempo's own server
  port/self-metrics (`tempo-metrics.internal.<root_domain>`) are
  internal-ALB-only, using OTLP/HTTP (port 4318)/plain HTTP (ports
  9009/12345/3200) rather than gRPC so all of them can use the existing
  plain-HTTP internal listener, the same as every other internal
  app-to-app route in this repo - a gRPC target group would need the
  internal HTTPS listener plus SNI certificate coverage, which isn't worth
  it here.
- Alloy (`alloy.tf`, `docker/alloy/`) sits in front of Tempo as the OTLP
  entry point for all three apps (forms-admin, forms-runner, and its queue
  worker - see `infra/deployments/forms/tfvars/dev.tfvars`), rather than
  them sending to Tempo directly. It does two things: drops
  forms-runner-queue-worker's internal SolidQueue dispatch/polling spans
  before they reach Tempo at all (`docker/alloy/config.alloy`'s
  `otelcol.processor.filter` - the same noise this module's dashboards
  otherwise have to filter out at query time), and scrapes its own metrics
  plus Mimir's and Tempo's (all reachable over their existing internal ALB
  endpoints - `tempo-metrics.internal.<root_domain>` was added specifically
  for this, since Tempo's server port wasn't otherwise exposed via any
  stable hostname) into Mimir, giving the tracing pipeline itself some
  observability where previously there was none. Its own config needs no
  gomplate/templating (unlike Tempo's and Mimir's images) - Alloy's config
  language has native environment-variable support (`sys.env(...)`).
  Beyla (eBPF zero-code instrumentation, considered for the still-uninstrumented
  forms-product-page) isn't used anywhere in this stack - AWS Fargate doesn't
  support eBPF at all, so it isn't an option regardless of how it's
  configured. Replacing the ADOT sidecar with Alloy as a single unified
  collector was also considered and left out of scope - that lives in the
  shared `infra/modules/ecs-service` module used by every app, a much bigger
  blast radius than anything else in this module, and it isn't broken today
  (traces already bypass it via direct OTLP, only the CloudWatch metrics path
  still uses it).
- Neither the tempo/grafana task, the mimir task, nor the alloy task has
  internet egress (see `security-groups.tf`), so all four images are pulled
  from our own ECR rather than Docker Hub directly - see the one-time setup
  above. This is also why several Grafana update-check / telemetry
  background jobs are explicitly disabled in `ecs.tf` (they'd otherwise just
  time out repeatedly against grafana.com), and why Mimir's
  `usage_stats.enabled` is set to `false`
  (`docker/mimir/mimir.yaml.tmpl`).
- `docker/grafana/datasources.yaml` pins the Tempo datasource to `uid: tempo`
  and the metrics datasource to `uid: prometheus` rather than letting
  Grafana auto-generate one, so dashboard JSON can reference a stable
  datasource uid instead of an opaque generated string. The metrics
  datasource is named "Mimir" (it's actually Mimir now, not Prometheus) but
  deliberately keeps `uid: prometheus` - all five dashboard JSON files
  reference that uid in every panel, and renaming it would mean touching
  every one of them for a purely cosmetic reason. This is baked in at image
  build time, so it takes effect on the next deploy like everything else
  here (see one-time setup above).
- `docker/grafana/dashboards/*.json` are provisioned from file (like
  `datasources.yaml`), via `docker/grafana/dashboards-provisioning.yaml`
  (`COPY`'d to `/etc/grafana/provisioning/dashboards/forms-tracing-poc.yaml`)
  pointing at `/etc/grafana/dashboards`, which the whole `dashboards/`
  directory is `COPY`'d into. This is why the dashboards needed baking into
  the image at all: Grafana's own state (`grafana.db`) is on the same
  ephemeral container filesystem as everything else here and does **not**
  survive a task restart, so dashboards created only through the API/UI
  would otherwise be lost entirely. The provider
  targets the existing `forms-tracing-poc` folder by uid, and each JSON's own
  `uid` matches what's already live, so redeploying updates these dashboards
  in place rather than duplicating them.
  - `allowUiUpdates: true`, though it doesn't do what its name suggests:
    Grafana's periodic reconcile reverts any UI/API edit back to the
    committed JSON on its next tick regardless of this setting.
    `updateIntervalSeconds` is set to `43200` (12h), so a live edit has a
    real window to test in before it reverts - not a permanent fix, just
    long enough to iterate in a session. Re-export (`get_dashboard_by_uid`)
    and commit anything worth keeping before the next reconcile or redeploy.
    New dashboards not yet present in this directory aren't affected at all
    (nothing to revert to), so those can be iterated on live indefinitely
    before being exported here for the first time.
