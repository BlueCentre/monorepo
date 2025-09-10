## rs-springboot-app Skaffold Developer Workflow

This service supports a unified developer experience via `skaffold build|test|run|dev`.

### Commands

```bash
# Build container image (local, not pushed)
skaffold build -m rs-springboot-app

# Run tests (hermetic Bazel integration tests via custom test phase)
skaffold test -m rs-springboot-app

# Deploy (build + deploy manifests)
skaffold run -m rs-springboot-app -p dev

# Continuous development (file sync + rebuilds + port-forward)
skaffold dev -m rs-springboot-app -p dev
```

### What the Test Phase Does
Runs the following Bazel tests before deployment:

- `SmokeNonWebIntegrationTest` – boots the app and validates basic non-web startup behavior.
- `HealthReadinessMetricsIntegrationTest` – consolidated probe + metrics validation (`/actuator/health`, `/actuator/health/readiness`, custom metrics, `/actuator/prometheus`).
- `BuildInfoIntegrationTest` – validates stamped build info exposure.

### Excluded / Manual Tests
`JUnit5SampleTest` is tagged `manual` while JUnit 5 native runner integration is evaluated. It won’t block the pipeline.

### Port Forward & Local Verification
When running `skaffold dev` or after `skaffold run`:

```bash
curl -f http://localhost:8080/actuator/health
curl -f http://localhost:8080/actuator/health/readiness
curl -f http://localhost:8080/actuator/prometheus | grep app_startup_invocations_total
```

### Cleanup
```bash
skaffold delete -m rs-springboot-app -p dev
```

### Future Improvements
* Replace manual JUnit5 sample with a console-launcher based `sh_test` or dedicated Bazel JUnit5 rule.
* Add optional arm64 image once base is mirrored internally.