# shellcheck shell=bash disable=SC1083,SC2034
# From ../.env
#VOLUMES=

MARIADB_ROOT_PASSWORD="op://Applications/MARIADB/password"
POSTGRES_ROOT_PASSWORD="op://Applications/POSTGRES/password"
PAPERLESS_DBPASS="op://Applications/PAPERLESS/postgres"

PHOTOPRISM_ADMIN_PASSWORD="op://Applications/PHOTOPRISM/password"
PHOTOPRISM_DATABASE_DSN="op://Applications/PHOTOPRISM/database-dsn"
PHOTOPRISM_DB_PASSWORD="op://Applications/PHOTOPRISM/db-password"

FILEHOST="op://Applications/FILESERVER/address"
DOMAIN="op://Applications/PROXY/DOMAIN"
