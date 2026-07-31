# Dashboards

Provisioned into Grafana from this directory - see `../README.md` for how these
survive redeploys (`dashboards-provisioning.yaml`, baked into the image at
build time). All live in the `forms-tracing-poc` folder.

## Forms - Service Overview (`forms-svc-overview.json`)

Top-level health across all traced services (forms-admin, forms-runner,
forms-runner-queue-worker): request rate, error rate, and SERVER-span latency
(p50/p90/p99) against the real SLO thresholds from
`infra/deployments/forms/health/slos.tf`, a service map (Tempo's
service-graph view), total call count, and an overall error % stat.

## Forms - Latency by Route (`forms-latency-routes.json`)

Per-route latency drill-down for a single selected service: request rate by
route, p90/p99 tables, a latency heatmap, p90/p99 vs SLO threshold lines, and
a table of slow (>500ms) traces.

## Forms - Errors & Health (`forms-errors-health.json`)

Error rate over time, a TraceQL search for `{status=error}`, HTTP 5xx traces
by route, dependency call volume, and outbound (CLIENT-span) error rate.

## Forms - Submission Job Producer (`forms-jobs-producer.json`)

The enqueue side of form submission: publish rate/latency/error rate for the
`submissions publish` span (forms-runner), recent publish traces, and
SolidQueue enqueue-side DB activity. See **Forms - Queue Worker** for the
processing side - there's no direct trace link between the two, since
SolidQueue hands off jobs via DB polling, not propagated trace context.

## Forms - Queue Worker (`forms-queue-worker.json`)

The processing side: SolidQueue's internal polling overhead vs real job
execution, job processing rate/latency/error rate by job, recent job traces
(filtered to exclude polling noise), dependency call volume, and a
jobs-processed-per-hour stat.

## Forms - Tracing Pipeline Health (`forms-pipeline-health.json`)

Health of the tracing infrastructure itself (Alloy, Mimir, Tempo), not the
apps being traced. Up/down status, CPU/memory against each component's actual
resource allocation, Mimir active series, Tempo live traces and
service-graph/span-metrics active series, the OTLP span flow from Alloy
through to Tempo (showing the SolidQueue noise-filter's effect), and Mimir's
own ingestion rate, query rate, query latency, and S3 block-shipper
success/failure.

## Forms - Submission Delivery & Notifications (`forms-delivery-notifications.json`)

Confirmation emails, submission delivery (email/S3/batch), and the
background jobs that poll for SES bounce/complaint/delivery-confirmation
events. Rate/latency/error panels are queue-level (Tempo's span-metrics
aren't configured with a custom dimension to split by job class), but the
recent-traces tables use TraceQL directly to show the actual job class
(`code.namespace`) and, for emails, the real subject line per send.
