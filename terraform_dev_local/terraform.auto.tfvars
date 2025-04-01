kubernetes_context = "colima"
region             = "us-central1"

# Enable services
cert_manager_enabled     = true
external_secrets_enabled = true
external_dns_enabled     = false
opentelemetry_enabled    = true
datadog_enabled          = false
istio_enabled            = true
redis_enabled            = true
cnpg_enabled             = true
mongodb_enabled          = true
argocd_enabled           = false
telepresence_enabled     = false

# Cloudflare API token
cloudflare_api_token = "REPLACE_WITH_CLOUDFLARE_API_TOKEN"

# Datadog API key
datadog_api_key = "REPLACE_WITH_DATADOG_API_KEY"

# Redis settings for rate limiting
redis_password = "REPLACE_WITH_REDIS_PASSWORD" # For demo/testing only - use a secure password in production

# MongoDB settings for application usage
mongodb_password = "REPLACE_WITH_MONGODB_PASSWORD" # For demo/testing only - use a secure password in production

# CNPG settings for application usage
cnpg_app_db_password = "REPLACE_WITH_CNPG_APP_DB_PASSWORD"
