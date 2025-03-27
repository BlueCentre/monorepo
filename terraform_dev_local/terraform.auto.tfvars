kubernetes_context = "colima"
region = "us-central1"

cert_manager_enabled = true
external_secrets_enabled = true
external_dns_enabled = false
opentelemetry_enabled = true
datadog_enabled = false
istio_enabled = true
cnpg_enabled = true
argocd_enabled = false
telepresence_enabled = false

# Cloudflare API token
cloudflare_api_token = "REPLACE_WITH_CLOUDFLARE_API_TOKEN"

# Datadog API key
datadog_api_key = "REPLACE_WITH_DATADOG_API_KEY"

# Redis settings for rate limiting
redis_enabled = true  # Set to true to enable Redis for testing
redis_password = "redis-password"  # For demo/testing only - use a secure password in production
