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

- Tempo + Grafana: one ECS task (`ecs.tf`), Grafana → Tempo over
  `localhost:3200`. Mimir: separate service (`mimir.tf`), reached over the
  internal ALB (`mimir.internal.<root_domain>`).
- Trace storage: S3 via `secure-bucket` (`s3.tf`), task-role IAM, no static
  credentials.
- Service-graph/span-metrics: Tempo's `metrics_generator` writes to Mimir
  (`docker/tempo/tempo.yaml.tmpl`), linked via `serviceMap.datasourceUid`
  (`datasources.yaml`). Mimir's write path is Distributor → Ingester
  (in-memory + local WAL) → S3, flushed every 2h
  (`tsdb.block-ranges-period`). Up to ~2h of recent data lives only on the
  container's ephemeral disk and is lost on restart; everything older is
  durable in S3.
- Mimir deploy: no rolling overlap (`deployment_maximum_percent = 100`,
  `deployment_minimum_healthy_percent = 0`),
  `availability_zone_rebalancing = "DISABLED"` (`mimir.tf`). No EFS/shared
  mount, so a normal 200/100 rolling deploy would likely also work.
- Grafana UI: public, via CloudFront + ALB (`alb.tf`), basic auth. OTLP
  ingestion (`alloy-otlp`/`tempo-otlp.internal.<root_domain>`), Mimir
  (`mimir.internal.<root_domain>`), Tempo self-metrics
  (`tempo-metrics.internal.<root_domain>`): internal-ALB-only, plain HTTP
  (ports 4318/9009/12345/3200), not gRPC.
- Alloy (`alloy.tf`, `docker/alloy/`): OTLP entry point for forms-admin,
  forms-runner, and its queue worker (`dev.tfvars`). Drops
  forms-runner-queue-worker's SolidQueue polling spans before Tempo
  (`config.alloy`'s `otelcol.processor.filter`). Scrapes its own/Mimir's/
  Tempo's metrics into Mimir. Config uses `sys.env(...)`, no
  templating step. Beyla not used - Fargate has no eBPF support.
  ADOT-replacement considered, out of scope - lives in the shared
  `infra/modules/ecs-service` module, bigger blast radius.
- Alloy's `tail_sampling`: keep errors, keep traces over 1000ms (matches
  the `admin`/`runner_http_latency_1000ms` SLOs), ratio-sample the rest.
  Requires the SDK head sampler (`opentelemetry_head_sampler_ratio`) near
  1.0 - sampling before Alloy sees the trace defeats the point. Policy is
  not baked into the image: `config.alloy`'s `import.http` polls an S3
  object (`alloy-remote-config.tf`, source in
  `alloy-remote-config/tail-sampling.alloy`) every 30s and hot-reloads -
  edit + `terraform apply`, no image rebuild/redeploy. `remotecfg` not
  used (needs a Fleet Management API server, not a static file). S3
  access: anonymous `GetObject` scoped to `aws:SourceVpc` (`import.http`
  has no SigV4 support). `alloy validate` runs in pre-commit/CI
  (`alloy-ci.yml`, mise-pinned) - behaviour on a malformed-but-fetched
  config is untested.
- No task here has internet egress (`security-groups.tf`) - all images
  pulled from ECR. Grafana's update-check/telemetry jobs disabled in
  `ecs.tf`; Mimir's `usage_stats.enabled = false`
  (`docker/mimir/mimir.yaml.tmpl`).
- `datasources.yaml` pins `uid: tempo`/`uid: prometheus` for stable
  dashboard references. Metrics datasource is named "Mimir" but keeps
  `uid: prometheus` (renaming would touch every dashboard panel). Baked in
  at image build time.
- CloudWatch datasource (`cloudwatch-datasource.tf`): read-only IAM on
  `aws_iam_role.tempo_task`, `authType: default`, no keys. No
  trace-to-logs link - `tracesToLogsV2` only supports
  Loki/Elasticsearch/Splunk/OpenSearch/Falcon LogScale/Google Cloud
  Logging/VictoriaMetrics Logs as a target, not CloudWatch. Jump manually:
  search the CloudWatch datasource by `otel_trace_id` (not `trace_id`,
  which is the ALB's `X-Amzn-Trace-Id` header and doesn't match Tempo's
  trace ID). Needs the `monitoring` and `oam` VPC endpoints
  (`environment/endpoints.tf`) - no internet egress, so those calls hang
  without them. `ec2` endpoint skipped (region discovery only, optional -
  `defaultRegion` is fixed).
- Dashboards (`docker/grafana/dashboards/*.json`): provisioned from file
  (`dashboards-provisioning.yaml`), baked into the image - Grafana's own
  DB doesn't survive a task restart. `allowUiUpdates: true` doesn't
  persist edits: reconcile reverts to the committed JSON every
  `updateIntervalSeconds` (12h). Export (`get_dashboard_by_uid`) and
  commit before that, or before a redeploy.
