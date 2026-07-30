# tempo

A throwaway proof-of-concept deployment of Grafana Tempo + Grafana on ECS
Fargate, used to evaluate Tempo as an alternative to X-Ray for application
tracing. Deployed only via `infra/deployments/forms/tempo`, dev environment
only. Not intended to be productionised as-is.

This module does not build or push its own images through a pipeline - the
two custom images (`docker/tempo`, `docker/grafana`) are built and pushed by
hand. This is deliberate: it's a POC, and setting up a CodeBuild/CodePipeline
for it isn't worth the extra infrastructure.

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

### 2. Build and push both images

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

Re-run this whenever `docker/tempo` or `docker/grafana` change (e.g. a new
Tempo/Grafana version, a config template change). Bucket name/region are
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

- Tempo + Grafana run as two containers in a single ECS task (`ecs.tf`),
  sharing the task's network namespace - Grafana reaches Tempo over
  `localhost:3200`.
- Trace storage is S3 (`s3.tf`, via the `secure-bucket` module), so traces
  survive task restarts, unlike the upstream docker-compose example's local
  disk. The Tempo task role has the minimal IAM permissions Tempo's docs
  recommend; no static credentials are used - Tempo picks up the task role
  via the default AWS SDK credential chain.
- Grafana's UI is exposed publicly via the existing CloudFront distribution
  and public ALB (`alb.tf`), behind basic auth. OTLP trace ingestion
  (`tempo-otlp.internal.<root_domain>`) is internal-ALB-only, using OTLP/HTTP
  (port 4318) rather than gRPC so it can use the existing plain-HTTP internal
  listener, the same as every other internal app-to-app route in this repo -
  a gRPC target group would need the internal HTTPS listener plus SNI
  certificate coverage, which isn't worth it here.
