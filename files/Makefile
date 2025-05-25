include ../compose.mk

/etc/cron.d/compose-files:
	@# Help: Create /etc/cron.d/compose-files
	@test -d /etc/cron.d && cp crontab /etc/cron.d/compose-files

.PHONY: init-db
init-db: .env
	@# Help: Initialize database users for Paperless and PhotoPrism
	@echo "Initializing database users..."
	@set -a; source .env; set +a; \
	docker exec files-postgres /usr/local/bin/db-init paperless paperless "$${PAPERLESS_DBPASS}" && \
	docker exec files-mariadb /usr/local/bin/db-init photoprism photoprism "$${PHOTOPRISM_DB_PASSWORD}" && \
	echo "Database initialization completed."

down::
	rm -f /etc/cron.d/compose-files

# Add init-db to all deployment targets
deploy:: init-db /etc/cron.d/compose-files
deploy-recreate:: init-db /etc/cron.d/compose-files
dev:: init-db
dev-recreate:: init-db
