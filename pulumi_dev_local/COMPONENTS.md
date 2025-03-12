# Supported Components

This document provides detailed information about the components that are currently supported and deployed in the Pulumi local development environment. Each component is designed to provide essential functionality for local Kubernetes-based application development.

## Core Components

### Cert Manager

**Status**: ✅ Active  
**Version**: v1.17.0  
**Namespace**: cert-manager

Cert Manager provides automated certificate management capabilities in Kubernetes:

- **Features**:
  - Automates the issuance and renewal of TLS certificates
  - Supports multiple issuers including Let's Encrypt, Vault, and self-signed certificates
  - Includes Custom Resource Definitions (CRDs) for Certificate, Issuer, ClusterIssuer, etc.
  - Simplifies certificate management for Kubernetes services and ingresses

- **Deployment Details**:
  - Deployed via Helm chart from https://charts.jetstack.io
  - CRDs installed automatically
  - Running in dedicated namespace: cert-manager

- **Documentation**: [Cert Manager Official Documentation](https://cert-manager.io/docs/)

### OpenTelemetry Stack

**Status**: ✅ Active  
**Components**:
- OpenTelemetry Operator (v0.79.0)
- OpenTelemetry Collector (v0.79.0)

**Namespace**: opentelemetry

The OpenTelemetry deployment includes a complete observability solution:

- **OpenTelemetry Operator**:
  - Manages OpenTelemetry Collector instances and instrumentation
  - Provides Custom Resource Definitions for OpenTelemetry components
  - Uses the OpenTelemetry Collector Contrib image for extended functionality

- **OpenTelemetry Collector**:
  - Collects, processes, and exports telemetry data
  - Deployed in "deployment" mode
  - Supports collecting metrics, traces, and logs from applications
  - Can be configured to export data to various backends

- **Deployment Details**:
  - Both components deployed via Helm charts from https://open-telemetry.github.io/opentelemetry-helm-charts
  - Operator manages collector instances through CRDs
  - Running in dedicated namespace: opentelemetry

- **Documentation**: [OpenTelemetry Documentation](https://opentelemetry.io/docs/)

### Istio Service Mesh

**Status**: ✅ Active  
**Version**: 1.23.3  
**Components**:
- Istio Base
- Istio CNI
- Istio Control Plane (istiod)
- Istio Ingress Gateway

**Namespace**: istio-system

Istio provides a complete service mesh solution:

- **Istio Base**:
  - Provides the foundation for Istio components
  - Installs Custom Resource Definitions (CRDs)
  - Sets up namespace and RBAC

- **Istio CNI**:
  - Configures Container Network Interface for Istio
  - Eliminates the need for privileged init containers
  - Improves security posture

- **Istio Control Plane (istiod)**:
  - Core service mesh functionality
  - Traffic management
  - Security policy enforcement
  - Telemetry collection

- **Istio Ingress Gateway**:
  - External traffic management
  - Configured with:
    - HTTP port: 80 (targeting 8080)
    - HTTPS port: 443 (targeting 8443)
    - Service type: ClusterIP (for local development)

- **Deployment Details**:
  - All components deployed via Helm charts from https://istio-release.storage.googleapis.com/charts
  - Running in dedicated namespace: istio-system
  - Ingress Gateway can be accessed through port-forwarding

- **Port Forwarding Example**:
  ```bash
  kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80
  ```

- **Basic Gateway Configuration Example**:
  ```yaml
  apiVersion: networking.istio.io/v1beta1
  kind: Gateway
  metadata:
    name: example-gateway
    namespace: your-app-namespace
  spec:
    selector:
      istio: ingressgateway
    servers:
    - port:
        number: 80
        name: http
        protocol: HTTP
      hosts:
      - "*"
  ```

- **Documentation**: [Istio Documentation](https://istio.io/latest/docs/)

## Configuration Harmonization

The Helm values for all components in this Pulumi implementation have been synchronized with the Terraform implementation to ensure consistency. Key configuration aspects now aligned include:

### Cert Manager
- Uses global leader election namespace configuration
- Explicitly configures CRD installation with `crds.enabled: true` and `crds.keep: true`
- Includes pod disruption budget for improved resilience

### OpenTelemetry Operator
- Uses `otel/opentelemetry-collector-k8s` image repository (aligned with Terraform)
- Explicitly creates CRDs with `crds.create: true`
- Configures leader election mechanism for high availability
- Sets up admission webhooks with cert-manager integration
- Includes certificate auto-generation configuration

### OpenTelemetry Collector
- Configures replica count explicitly
- Enables cluster metrics collection through presets
- Maintains deployment mode configuration

### Istio Base
- Explicitly enables Istio Config CRDs
- Maintains default revision setting

### Istio CNI
- Configures CNI binary directory for Kubernetes environments

### Istio Ingress Gateway
- Provides specific port mappings for HTTP and HTTPS traffic
- Uses ClusterIP service type for local development

### Benefits of Harmonized Configuration

1. **Consistency**: Both Pulumi and Terraform implementations now deploy identical configurations
2. **Maintainability**: Easier to maintain and update both implementations in parallel 
3. **Reliability**: Includes additional resilience settings across components
4. **Feature Parity**: Ensures all features work identically across both implementations

## Future Components

The following components are planned for future implementation:

### Argo CD

**Status**: 🔄 Planned  
Continuous delivery tool that follows the GitOps principles.

### Telepresence

**Status**: 🔄 Planned  
Local development tool for connecting local services to remote Kubernetes clusters.

### External Secrets

**Status**: 🔄 Planned  
Integration with external secret management systems like AWS Secrets Manager, HashiCorp Vault, etc.

### External DNS

**Status**: 🔄 Planned  
Automated DNS configuration for Kubernetes services.

### Datadog

**Status**: 🔄 Planned  
Application monitoring and analytics platform. 