# pulumi_lab_gmail

Pulumi program provisioning foundational personal GCP resources: Cloud Run, Cloud Storage, IAM, optional Cloud Build, and optional Cloudflare DNS automation for custom domains.

## Quickstart

Prerequisites:
* Go 1.25+
* Pulumi CLI authenticated
* gcloud CLI authenticated to target project
* (Optional) Cloudflare API token with DNS edit permissions

### 1. Clone & init
```bash
git clone <repo-url>
cd monorepo/pulumi_lab_gmail
pulumi stack init dev   # or choose existing stack
```

### 2. Configure (minimal)
```bash
# Optional custom domain (creates DomainMapping)
pulumi config set customDomain hello.run.ipv1337.dev

# Optional Cloudflare automation (choose one)
pulumi config set cloudflare:zoneId <ZONE_ID>
# OR
pulumi config set cloudflare:zoneName ipv1337.dev

# Cloudflare token (secret)
pulumi config set --secret cloudflare:apiToken <TOKEN>

# Recommended: keep DNS unproxied for issuance
pulumi config set cloudflare:proxied false
```

### 3. Deploy
```bash
pulumi up
```

Key outputs (prefix = stack resource root):
* `...cloudrunURL` – Cloud Run service URL
* `...cloudrunCustomDomain` – Custom domain (if set)
* `...cloudrunDomainMappingTarget` – CNAME target (resolved or fallback)
* `...cloudrunCloudflareRecordName` / `...cloudrunCloudflareZoneId` – Only when DNS automation active

## Configuration Reference
| Key | Required | Description |
|-----|----------|-------------|
| customDomain | no | Full domain for DomainMapping (e.g. `hello.run.ipv1337.dev`) |
| cloudflare:zoneId | no* | Zone ID for DNS automation (*required if token present & customDomain set without zoneName) |
| cloudflare:zoneName | no* | Zone name; resolved to ID (*same rule as above) |
| cloudflare:apiToken | no | API token (secret). If provided with customDomain must pair with zoneId/zoneName or guard fails |
| cloudflare:proxied | no | Boolean; default false recommended for certificate provisioning |
| multiServices | no | JSON array describing extra Cloud Run services (see below) |

Validation Guard: If `customDomain` + API token present but neither `zoneId` nor `zoneName` set, deployment fails fast.

Environment alternative: `CLOUDFLARE_API_TOKEN` can supply the token (still subject to guard logic).

## Multi-service Deployment Pattern
Provide multiple services via `multiServices` config. Example (with per-service environment variables):
```bash
pulumi config set multiServices '[
	{"name":"api","image":"gcr.io/cloudrun/hello","customDomain":"api.run.ipv1337.dev","env":{"MODE":"api","LOG_LEVEL":"debug"}},
	{"name":"worker","image":"gcr.io/cloudrun/hello","env":{"MODE":"worker"}}
]'
pulumi up
```
Entry schema:
| Field | Required | Notes |
|-------|----------|-------|
| name | yes | Unique service name (used in Cloud Run + resource naming) |
| image | yes | Container image reference |
| customDomain | no | Full domain; same validation rules |
| region | no | Override region (defaults to global stack region) |
| env | no | Object map of KEY:VALUE pairs injected as plain environment variables |

Generated resource name pattern: `personal-llc-<name>-cloudrun`.

Update or remove services by editing the JSON and re-running `pulumi up` (Pulumi computes create/update/destroy).

## What It Provisions
* Enables required GCP APIs
* Storage bucket
* Service account & IAM role bindings
* Optional Cloud Build placeholder
* One primary Cloud Run service (`hello`) + optional additional services
* Optional DomainMapping per service if `customDomain` set
* Optional Cloudflare CNAME (only when zone info + token present)

## Domain Mapping & DNS
`...cloudrunDomainMappingTarget` attempts to read Cloud Run status resource records; falls back to `ghs.googlehosted.com` until populated. Re-run `pulumi up` after DomainMapping becomes Ready to update DNS if necessary.

## Troubleshooting
* DomainMapping Pending: ensure DNS CNAME exists (unproxied initially) and wait for certificate issuance.
* Guard failure: add `cloudflare:zoneId` or `cloudflare:zoneName`.
* Wrong CNAME value: wait & re-run; Cloud Run may not have populated resourceRecords yet.

## Removing Resources
```bash
pulumi destroy
```

## Security Notes
Store tokens with `--secret`. Outputs do not expose secret values. DNS automation skipped when token absent.

## Future Enhancements (Potential)
* Wildcard domain support
* Per-service Cloudflare proxied toggle
* Health check & rollout strategies

---
This file is auto-maintained alongside infrastructure code. Keep edits scoped and additive.
