# rs_springboot_app Modernized Build

Spring Boot service migrated to Bazel `rules_spring` + `rules_oci` (Bzlmod) producing a reproducible distroless-based OCI image with a layered layout.

## Key Targets

| Target | Description |
|--------|-------------|
| `:demoapp` | Spring Boot executable (fat) jar |
| `:demoapp_image` | OCI image (linux/amd64) built from distroless Java 17 |
| `:demoapp_image_tar` | `oci_load` generated tar (Docker-compatible) |
| `:demoapp_smoke_test` | Runtime smoke test (startup + log assertion) |
| `:demoapp_image_structure_test` | Verifies image layers contain metadata + jar |
| `:metadata_layer_tar` | Small metadata layer (info/authors) |
| `:demoapp_image_index` | Placeholder multi-arch index referencing amd64 image |
| `:demoapp_push` | Pushes image to a remote registry (update tag first) |
| `/healthz` | Liveness endpoint (JSON status) |
| `/readyz` | Readiness endpoint (JSON ready flag) |

## Build & Test

```bash
# Build base jar + image
bazel build //projects/java/rs_springboot_app:demoapp_image

# Export image tar (will appear under bazel-bin/...)
bazel run //projects/java/rs_springboot_app:demoapp_image_tar

# Run smoke + structure tests
bazel test //projects/java/rs_springboot_app:demoapp_smoke_test --test_output=all
bazel test //projects/java/rs_springboot_app:demoapp_image_structure_test --test_output=all
```

## Load Image Into Docker

```bash
tarfile=$(bazel cquery --output=files //projects/java/rs_springboot_app:demoapp_image_tar)
docker load -i "$tarfile"
docker run --rm -p 8080:8080 rs-springboot-app:latest
```

## Multi-Arch (Scaffolding)

`oci_image_index` currently references only the amd64 variant:

```bash
bazel build //projects/java/rs_springboot_app:demoapp_image_index
```
Extend by producing additional images (e.g. `demoapp_image_arm64`) and updating `images = {"linux/amd64": ..., "linux/arm64": ...}`.

## Pushing (Configure Registry First)

Update the placeholder remote tag in the BUILD file, then:

```bash
bazel run //projects/java/rs_springboot_app:demoapp_push
```
Add `--stamp` for stamped tags or supply a `tag` file as needed.

## Layering Strategy

```text
metadata_layer_tar  -> meta/info.txt, meta/author.txt (small, change-friendly)
demoapp_jar_tar     -> app/demoapp.jar (large, stable)
```
This improves cache efficiency: metadata edits avoid repackaging the large jar layer.

## Skaffold Integration

This service already has its own Skaffold config: `projects/java/rs_springboot_app/skaffold.yaml`.

Continuous development (rebuild + redeploy + port-forward) is as simple as:

```bash
skaffold dev -f projects/java/rs_springboot_app/skaffold.yaml
```

That command:
1. Uses the Bazel builder to build the image target `//projects/java/rs_springboot_app:demoapp_image`.
2. Applies the Kubernetes manifests under `kubernetes/` (deployment + service).
3. Port-forwards service `rs-springboot-app` port 8080 locally.

You do NOT need to run `docker load` or `docker run` manually during iterative work—`skaffold dev` handles incremental rebuilds and live reload.

For a one-off build & deploy without continuous watch:

```bash
skaffold run -f projects/java/rs_springboot_app/skaffold.yaml
```

## HTTP Endpoints

| Path | Purpose | Example |
|------|---------|---------|
| `/` | Sample baseline endpoint | `curl :8080/` -> `Hello!` |
| `/healthz` | Legacy/custom liveness (controller) | `curl :8080/healthz` |
| `/readyz` | Legacy/custom readiness (controller) | `curl :8080/readyz` |
| `/actuator/health/liveness` | Actuator liveness group | `curl :8080/actuator/health/liveness` |
| `/actuator/health/readiness` | Actuator readiness group | `curl :8080/actuator/health/readiness` |
| `/actuator/prometheus` | Prometheus scrape endpoint | `curl :8080/actuator/prometheus` |
| `/actuator/info` | Build & git metadata (generated) | `curl :8080/actuator/info` |

Kubernetes probes now point to the actuator group endpoints. Controller endpoints retained for backwards compatibility / manual debugging.

### Metrics

Custom Micrometer counter `app.startup.invocations` is registered and incremented once the application reaches the `ApplicationReadyEvent`.

Expose metrics via actuator (enabled in `application.properties`):

```properties
management.endpoints.web.exposure.include=health,metrics,prometheus,info
management.metrics.export.prometheus.enabled=true
``` 

Query the metric (after startup):

```bash
curl :8080/actuator/metrics/app.startup.invocations | jq
```

Example response excerpt:

```json
{
  "name": "app.startup.invocations",
  "measurements": [ { "statistic": "COUNT", "value": 1.0 } ]
}
```

Associated Bazel integration test: `//projects/java/rs_springboot_app:HealthMetricsIntegrationTest` which boots the app on a random port and validates both `/actuator/health` and the custom metric exposure.

### Prometheus Scrape

Prometheus endpoint enabled via:

```properties
management.endpoints.web.exposure.include=health,metrics,prometheus
management.metrics.export.prometheus.enabled=true
```

Scrape example (`prometheus.yml` snippet):

```yaml
scrape_configs:
  - job_name: rs-springboot-app
    metrics_path: /actuator/prometheus
    static_configs:
      - targets: ["rs-springboot-app.default.svc.cluster.local:8080"]
        labels:
          app: rs-springboot-app
```

### JVM Tuning Layer

`jvm/jvm.args` added as a distinct OCI layer (`jvm_args_tar`) to allow rapid tuning without invalidating the large application jar layer.

Current options (conservative):

```conf
-XX:InitialRAMPercentage=25.0
-XX:MaxRAMPercentage=70.0
-XX:+UseG1GC
-XX:MaxGCPauseMillis=200
-XX:+AlwaysActAsServerClassMachine
-XX:+UseStringDeduplication
-XX:+HeapDumpOnOutOfMemoryError
-XX:HeapDumpPath=/tmp

```

Update `jvm/jvm.args` and rebuild image; only small layer rebuilt.

### Resources

Deployment sets conservative defaults:

```text
requests: cpu 50m / memory 128Mi
limits:   cpu 250m / memory 256Mi
```

Tune per environment; keep request/limit ratio reasonable to avoid CPU throttling.

### Build Metadata (Stamped) - `/actuator/info`

Build metadata is now produced hermetically (source-state dependent) via Bazel stamping:

1. Workspace status script: `scripts/workspace_status.sh` emits stable (SCM) and volatile (user/host/time) keys.
2. Macro: `//tools/build:build_info.bzl` provides `stamped_build_info` generating `META-INF/build-info.properties`.
3. Application `BUILD.bazel` loads the macro and adds the produced file as a resource.
4. A custom `BuildInfoContributor` shapes the JSON exposed by `/actuator/info` into a stable nested structure.

Invoke with stamping (recommended for CI):

```bash
bazel build //projects/java/rs_springboot_app:demoapp --stamp \
  --workspace_status_command=scripts/workspace_status.sh
```

Sample output:

```json
{
  "build": {
    "version": "0.1.0",
    "time": "2025-09-09T07:40:12Z",
    "user": "jane",
    "host": "devbox",
    "git": {
      "branch": "feature-x",
      "commit": "1a2b3c4d5e6f",
      "dirty": "clean"
    }
  }
}
```

Keys are intentionally normalized (no `build.` prefix in JSON) for downstream clarity. Missing fields simply result in an absent key (no failures).

Associated validation test: `//projects/java/rs_springboot_app:BuildInfoIntegrationTest`.

## Reproducibility

Base image pinned by digest (distroless java17). For SLSA-style provenance add stamped labels and SBOM generation (future enhancement).

## Future Improvements

* Add integration test hitting an HTTP endpoint (requires enabling `web` port and minimal controller).
* Add `oci_image` variant with JVM options layer (performance tuning).
* Implement real multi-arch build (separate toolchains, arm64 base pull + index).

## Upstream Documentation
 
See `rules_spring` repo for full macro capabilities: https://github.com/salesforce/rules_spring
