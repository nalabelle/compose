# Note: .env is read automatically by docker compose
DOCKER_SOCKET=/var/run/docker.sock
VOLUMES=${PWD}/volumes
CONFIGS=${PWD}/config
CACHE=${PWD}/.cache
SECRETS=${PWD}/_secrets

# General
HOSTNAME=
DOMAIN={{ op://Applications/PROXY/DOMAIN }}
ORG={{ op://Applications/PROXY/ORG }}
EMAIL={{ op://Applications/PROXY/EMAIL }}
METRICS_LONG_TERM_STORAGE={{ op://Applications/METRICS/long-term-storage }}

# home-automation
ZIGBEE_DEVICE=/dev/serial/by-id/usb-port0

# media
FILEHOST=
