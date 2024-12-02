# Note: .env is read automatically by docker compose
DOCKER_SOCKET=/var/run/docker.sock
VOLUMES=${PWD}/volumes
CONFIGS=${PWD}/config
CACHE=${PWD}/.cache
SECRETS=${PWD}/_secrets

# Compose projects on this host, space separated and quoted, e.g. "project1 project2"
PROJECTS=

# General
HOSTNAME=
DOMAIN={{ op://Applications/PROXY/DOMAIN }}
ORG={{ op://Applications/PROXY/ORG }}
EMAIL={{ op://Applications/PROXY/EMAIL }}
METRICS_RETENTION=

# home-automation
ZIGBEE_DEVICE=/dev/serial/by-id/usb-port0

# media
FILEHOST=
