# General
DOMAIN={{ op://Applications/ACME_DNS_STACKS_APPS/DOMAIN }}

# APPS
APPS__MINIFLUX__DATABASE_URL=postgres://{{ op://Applications/MINIFLUX/POSTGRES_USERNAME }}:{{ op://Applications/MINIFLUX/POSTGRES_PASSWORD }}@postgres/miniflux?sslmode=disable
APPS__MINIFLUX_SIDEKICK__API_KEY={{ op://Applications/MINIFLUX_SIDEKICK/password }}

# Postgres
POSTGRES__POSTGRES_PASSWORD={{ op://Applications/POSTGRES/password }}

# Proxy
PROXY__CF_ZONE_API_TOKEN={{ op://Applications/CF_ZONE_API_TOKEN/password }}
PROXY__CF_DNS_API_TOKEN={{ op://Applications/ACME_DNS_STACKS_APPS/CF_DNS_API_TOKEN }}
PROXY__CERT_EMAIL={{ op://Applications/ACME_DNS_STACKS_APPS/email }}
