# https://github.com/open-telemetry/opentelemetry-helm-charts/blob/main/charts/opentelemetry-operator/values.yaml

## Install CRDS with the right webhook settings
## These are installed as templates, so they will clash with existing OpenTelemetry Operator CRDs in your cluster that are not already managed by the helm chart.
## See https://github.com/open-telemetry/opentelemetry-helm-charts/blob/main/charts/opentelemetry-operator/UPGRADING.md#0560-to-0570 for more details.
crds:
  create: true

manager:
  collectorImage:
    repository: "otel/opentelemetry-collector-k8s"
  ## Enable leader election mechanism for protecting against split brain if multiple operator pods/replicas are started.
  ## See more at https://docs.openshift.com/container-platform/4.10/operators/operator_sdk/osdk-leader-election.html
  leaderElection:
    enabled: true

## Admission webhooks make sure only requests with correctly formatted rules will get into the Operator.
## They also enable the sidecar injection for OpenTelemetryCollector and Instrumentation CR's
admissionWebhooks:
  create: true
  ## https://github.com/open-telemetry/opentelemetry-helm-charts/blob/main/charts/opentelemetry-operator/README.md#tls-certificate-requirement
  ## TLS Certificate Option 1: Use certManager to generate self-signed certificate.
  ## certManager must be enabled. If enabled, always takes precedence over options 2 and 3.
  certManager:
    enabled: true
    ## Provide the issuer kind and name to do the cert auth job.
    ## By default, OpenTelemetry Operator will use self-signer issuer.
    issuerRef: {}
    # kind:
    # name:
    ## Annotations for the cert and issuer if cert-manager is enabled.
    certificateAnnotations: {}
    issuerAnnotations: {}
    # duration must be specified by a Go time.Duration (ending in s, m or h)
    duration: ""
    # renewBefore must be specified by a Go time.Duration (ending in s, m or h)
    # Take care when setting the renewBefore field to be very close to the duration
    # as this can lead to a renewal loop, where the Certificate is always in the renewal period.
    renewBefore: ""
  ## TLS Certificate Option 2: Use Helm to automatically generate self-signed certificate.
  ## certManager must be disabled and autoGenerateCert must be enabled.
  ## If true and certManager.enabled is false, Helm will automatically create a self-signed cert and secret for you.
  autoGenerateCert:
    enabled: true
    # If set to true, new webhook key/certificate is generated on helm upgrade.
    recreate: true
    # Cert period time in days. The default is 365 days.
    certPeriodDays: 365
