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
- Rate Limiting EnvoyFilters (when Redis is enabled)

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

- **Rate Limiting Configuration**:
  - Three EnvoyFilter resources for rate limiting:
    - `rate-limit-service`: Defines Redis as the rate limiting storage backend
    - `filter-ratelimit`: Configures the rate limit filter for HTTP traffic
    - `ratelimit-config`: Sets up the rate limit action based on request path

- **Deployment Details**:
  - All components deployed via Helm charts from https://istio-release.storage.googleapis.com/charts
  - Running in dedicated namespace: istio-system
  - Ingress Gateway can be accessed through port-forwarding
  - Rate limiting is configured to use Redis in the dedicated `redis` namespace

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

## Redis

**Status**: ✅ Active  
**Version**: 18.19.1  
**Namespace**: redis

Redis is a popular open-source, in-memory data structure store that can be used as a database, cache, message broker, and streaming engine. It supports various data structures such as strings, hashes, lists, sets, sorted sets, and more.

**Implementation**:  
Redis is implemented in the cluster using the Bitnami Redis Helm chart. It is deployed in a dedicated `redis` namespace to serve both the Istio rate limiting functionality and to provide Redis services for applications.

**Configuration**:  
- Deployed in the `redis` namespace
- 1 master and 2 replicas for high availability
- Authentication is enabled, requiring a password to access Redis
- Persistence is enabled with 8Gi storage for both master and replicas
- Exposed as a ClusterIP service within the cluster
- Network policies are enabled to allow connections from all namespaces
- Security contexts configured with appropriate user and group settings
- Redis connection details: `redis-master.redis.svc.cluster.local:6379`

**Dependencies**:  
- Kubernetes cluster
- Helm 3.x
- When used with Istio rate limiting, requires Istio to be enabled

**Configuration**:  
Enable or disable Redis via the Pulumi config:
```bash
pulumi config set dev-local-infrastructure:redis_enabled true
pulumi config set dev-local-infrastructure:redis_password your-secure-password --secret
```

**Usage**:  
Redis serves two primary purposes:
1. It is utilized by the Istio rate limiting service to store counters and enforce rate limits, integrating automatically with the rate limiting functionality.
2. It can be used by application developers for various use cases like caching, session storage, pub/sub messaging, etc.

To connect to Redis from an application:
```
REDIS_HOST=redis-master.redis.svc.cluster.local
REDIS_PORT=6379
```

**Istio Rate Limiting Integration**:
When both Redis and Istio are enabled, the system automatically deploys the following EnvoyFilter resources:
- `rate-limit-service`: Configures the Redis endpoint for rate limiting
- `filter-ratelimit`: Sets up the HTTP filter for rate limiting
- `ratelimit-config`: Defines rate limiting actions based on request path

**Notes**:  
- Redis is disabled by default and must be enabled in the Pulumi config (`redis_enabled = true`)
- For production use, consider increasing the number of replicas and using a secure password
- The multi-tenant setup allows developers to utilize Redis across different namespaces
- AOF persistence is enabled and RDB persistence is disabled for better durability 

## MongoDB

**Status**: Production Ready  
**Version**: 0.8.3 (Operator), 4.4.19 (MongoDB)  
**Namespace**: mongodb

MongoDB is a popular NoSQL database that stores data in flexible, JSON-like documents. It provides high availability, horizontal scaling, and geographic distribution.

### Implementation

MongoDB is implemented using the MongoDB Community Operator Helm chart from `https://mongodb.github.io/helm-charts`. The operator deploys and manages a MongoDB replica set in a dedicated `mongodb` namespace.

### Features
- Deployed in the `mongodb` namespace
- The MongoDB Community Operator manages the MongoDB deployment
- MongoDB version 4.4.19 is deployed in a replica set with 1 replica
- Secure storage with persistent volumes (8Gi)
- MongoDB password is stored in a Kubernetes secret
- The MongoDB instance is available as a Service within the cluster
- The connection string format for applications: `mongodb://root:password@mongodb-rs-0.mongodb-svc.mongodb.svc.cluster.local:27017/admin?replicaSet=mongodb-rs&ssl=false`

### Dependencies
- None

### Configuration Options

Enable or disable MongoDB via the Pulumi config:

```bash
pulumi config set dev-local-infrastructure:mongodb_enabled true
pulumi config set dev-local-infrastructure:mongodb_password your-secure-password --secret
```

### References
- [MongoDB Community Operator](https://github.com/mongodb/mongodb-kubernetes-operator)
- [MongoDB Community Operator Helm Chart](https://github.com/mongodb/helm-charts/tree/main/charts/community-operator) 