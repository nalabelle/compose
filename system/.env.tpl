# shellcheck shell=bash disable=SC1083,SC2034
# Alloy variables
ALLOY_API_KEY={{ op://Applications/ALLOY/password }}
ALLOY_REMOTE_WRITE_URL={{ op://Applications/ALLOY/remote-write-url }}

# Kopia variables
KOPIA_PASSWORD={{ op://Applications/KOPIA/password }}
KOPIA_SERVER_ADDRESS={{ op://Applications/KOPIA/server-url }}

# Traefik/Proxy variables
CF_DNS_API_TOKEN={{ op://Applications/PROXY/CF_DNS_API_TOKEN }}
CF_ZONE_API_TOKEN={{ op://Applications/PROXY/CF_ZONE_API_TOKEN }}
DOMAIN={{ op://Applications/PROXY/DOMAIN }}
