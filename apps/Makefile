include ../compose.mk

pre-deploy:: .env
	@# Help: Initialize database users for Wallabag and Miniflux
	@echo "Starting PostgreSQL container..."
	@docker compose up postgres -d
	@echo "Waiting for PostgreSQL to be ready..."
	@until docker exec apps-postgres pg_isready -U postgres; do sleep 1; done
	@echo "Initializing database users..."
	@set -a; source .env; set +a; \
	docker exec apps-postgres /usr/local/bin/db-init wallabag "$${WALLABAG_DATABASE_USER}" "$${WALLABAG_DATABASE_PASSWORD}" && \
	docker exec apps-postgres /usr/local/bin/db-init miniflux miniflux "$${MINIFLUX_POSTGRES_PASSWORD}" && \
	echo "Database initialization completed."

