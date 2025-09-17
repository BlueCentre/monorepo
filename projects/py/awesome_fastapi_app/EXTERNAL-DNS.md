# External-DNS Integration with Istio Gateway

This document provides detailed information about using external-DNS with Istio Gateway resources for automatic DNS record management in the template FastAPI application.

## Overview

External-DNS is a Kubernetes add-on that automatically creates and manages DNS records for Kubernetes resources. This template application is configured to work with external-DNS to automatically create DNS records for Istio Gateway resources, allowing your API to be accessible using a domain name.

## How It Works

1. The Istio Gateway and VirtualService resources in this template include annotations that external-DNS uses to identify resources that require DNS records.
2. When these resources are deployed, external-DNS detects them and creates the appropriate DNS records in your configured DNS provider.
3. The DNS records typically point to the external IP address of your Istio ingress gateway service.

## Prerequisites

Before using this feature:

1. External-DNS must be installed and properly configured in your cluster
2. External-DNS must be configured to watch Istio Gateway resources
3. You must have proper credentials configured for your DNS provider (e.g., Cloudflare, AWS Route53, etc.)

## Configuration

### 1. External-DNS Configuration

External-DNS must be configured with the following key settings:

```yaml
args:
  - --source=istio-gateway   # Add Istio Gateway source
  - --domain-filter=example.com  # Optional: limit to specific domains
  - --provider=cloudflare    # Your DNS provider
  - --policy=sync           # Policy for DNS record management
  - --registry=txt          # Use TXT records for ownership
```

### 2. Gateway Resource Annotations

The Gateway resource in this template includes the following annotations:

```yaml
annotations:
  external-dns.alpha.kubernetes.io/hostname: "api-hostname.example.com"
  external-dns.alpha.kubernetes.io/sync-enabled: "true"
```

These annotations tell external-DNS:
- Which hostname to create (`hostname`)
- That this Gateway should be processed by external-DNS (`sync-enabled`)

## Deployment and Usage

1. Configure your domain name in the Gateway and VirtualService resources:
   ```bash
   # Edit the gateway.yaml file
   vim kubernetes/istio/gateway.yaml
   
   # Change the hostname annotation to your domain
   external-dns.alpha.kubernetes.io/hostname: "your-api.example.com"
   ```

2. Deploy the application with Istio rate limiting:
   ```bash
   skaffold run -m template-fastapi-app -p istio-rate-limit
   ```

3. Wait for external-DNS to process the Gateway resource and create the DNS record (may take a few minutes).

4. Your API should now be accessible at your configured domain name.

## Troubleshooting

### Common Issues

1. **DNS records not being created**

   Verify external-DNS is configured with `istio-gateway` as a source:
   ```bash
   kubectl get deployment -n external-dns -o yaml | grep -A 20 args
   ```

2. **"Context deadline exceeded" errors in external-DNS logs**

   This typically indicates connectivity issues between external-DNS and your DNS provider's API. Check:
   - API token permissions
   - Network connectivity
   - Reduce the number of sources external-DNS is watching
   - Add a domain filter to limit the scope

3. **Wrong IP address in DNS records**

   Verify the external IP of your Istio ingress gateway:
   ```bash
   kubectl get service -n istio-system istio-ingressgateway
   ```

### Debugging Commands

Check external-DNS logs:
```bash
kubectl logs -n external-dns $(kubectl get pods -n external-dns -l app=external-dns -o name | head -n 1)
```

Verify Gateway resources and annotations:
```bash
kubectl get gateway -n template-fastapi-app -o yaml
```

Test DNS record creation manually:
```bash
# Get your zone ID (for Cloudflare)
curl -X GET "https://api.cloudflare.com/client/v4/zones?name=example.com" \
     -H "Authorization: Bearer YOUR_API_TOKEN" \
     -H "Content-Type: application/json"

# Create a test record
curl -X POST "https://api.cloudflare.com/client/v4/zones/ZONE_ID/dns_records" \
     -H "Authorization: Bearer YOUR_API_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"test-external-dns.example.com","content":"192.168.1.1","ttl":120,"proxied":false}'
```

## References

- [External-DNS Documentation](https://github.com/kubernetes-sigs/external-dns)
- [Istio Gateway API Documentation](https://istio.io/latest/docs/reference/config/networking/gateway/)
- [External-DNS Istio Tutorial](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/istio.md) 