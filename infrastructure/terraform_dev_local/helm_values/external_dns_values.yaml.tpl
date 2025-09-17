# https://github.com/bitnami/charts/blob/main/bitnami/external-dns/values.yaml
# https://github.com/kubernetes-sigs/external-dns/blob/master/charts/external-dns/values.yaml
# https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/cloudflare.md#using-helm

provider: cloudflare

# sigs: Reference external secret
env:
- name: CF_API_TOKEN
  valueFrom:
    secretKeyRef:
      name: ${cfSecretName}
      key: ${cfSecretKey}
# bitnami: Use ExternalSecret to store the Cloudflare API token instead (not used for some reason?)
# env:
# - name: CF_API_TOKEN
#   valueFrom:
#     secretKeyRef:
#       name: cloudflare-api-key
#       key: apiKey

# bitnami
# cloudflare:
#   proxied: false
#   # https://console.cloud.google.com/kubernetes/objectKind/external-secrets.io/externalsecrets?apiVersion=v1beta1&project=prj-lab-james-nguyen&supportedpurview=project
#   secretName: ${cfSecretName}

txtOwnerId: ${txtOwnerId}

# dryRun: true

policy: sync

interval: 30m

triggerLoopOnEvent: true

annotationFilter: ${annotationFilter}

sources:
- istio-gateway
# - service
# - ingress
# - gateway-httproute

# USAGE: service, ingress, gateway-httproute
# annotations:
#   external-dns.alpha.kubernetes.io/hostname: {hostname}
#   external-dns.alpha.kubernetes.io/sync-enabled: true
