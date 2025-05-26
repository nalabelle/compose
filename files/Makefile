include ../compose.mk

pre-deploy:: .env
	@# Help: Initialize database users for Paperless and PhotoPrism
	@echo "Starting PostgreSQL and MariaDB containers..."
	@docker compose up postgres mariadb -d
	@echo "Waiting for PostgreSQL to be ready..."
	@until docker exec files-postgres pg_isready -U postgres; do sleep 1; done
	@echo "Waiting for MariaDB to be ready..."
	@until [ "$$(docker inspect --format='{{.State.Health.Status}}' files-mariadb)" = "healthy" ]; do sleep 1; done
	@echo "Initializing database users..."
	@set -a; source .env; set +a; \
	docker exec files-postgres /usr/local/bin/db-init paperless paperless "$${PAPERLESS_DBPASS}" && \
	docker exec files-mariadb /usr/local/bin/db-init photoprism photoprism "$${PHOTOPRISM_DB_PASSWORD}" && \
	echo "Database initialization completed."
