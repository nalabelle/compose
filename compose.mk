SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

.DEFAULT_GOAL:=help

# Define crontab path based on current directory name
COMPOSE_CRONTAB_NAME ?= $(shell basename $(CURDIR))
COMPOSE_CRONTAB ?= /etc/cron.d/compose-$(COMPOSE_CRONTAB_NAME)

print-%:
	@echo $*=$($*)
showdeps-%:
	@$(MAKE) -nd "$*" | sed -rn "s/^(\s+)Considering target file '(.*)'\.$$/\1\2/p"
.PHONY: help
help:
	@{ LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null || true ; } \
		| awk -v RS= -F: '/^[^\n])/,/^\n$$/; \
		{ if($$1 ~ "^[#]" || $$1 ~ /^.PHONY/ || $$1 ~ /^\$$/) next; \
			target = match($$0, /^[^:]/); \
			if (target == 0) next; \
			help = match($$0, /\t@# Help: [^\n]+/); \
			if (help == 0) next; \
			helptext = substr($$0, RSTART+10, RLENGTH-10); \
			printf "%-25s\t%s\n", $$target, helptext; \
			}' \
		| sort

.PHONY: clean
clean:: down
	@# Help: Remove all generated files and docker containers/volumes
	rm -f .env
	docker rm --volumes

.env: .env.tpl $(wildcard .env.local) $(wildcard ../.env)
	@# Help: Load secrets from 1password
	@HOSTNAME=$${HOSTNAME:-$$(hostname)} && \
	TMP_ENV=$$(mktemp) && \
	{ test -f ../.env && cat ../.env; true; } > $$TMP_ENV && \
	if op inject -i .env.tpl >> $$TMP_ENV; then \
		{ test -f .env.local && echo "" && echo "# LOCAL OVERRIDES" && cat .env.local; true; } >> $$TMP_ENV && \
		mv $$TMP_ENV .env; \
	else \
		rm -f $$TMP_ENV; \
		echo "Error: op inject failed, .env not created"; \
		exit 1; \
	fi

.PHONY: pre-deploy
pre-deploy:: .env
	@# Help: Run pre-deployment tasks
	@true

.PHONY: pull
pull: compose.yaml .env
	@# Help: docker compose pull
	docker compose -f $< pull

.PHONY: dev-recreate
dev-recreate:: compose.yaml pre-deploy
	@# Help: Run docker compose in dev mode, recreating containers
	@if [ -f compose.dev.yaml ]; then \
		CMD="docker compose -f compose.yaml -f compose.dev.yaml up --force-recreate --remove-orphans -d"; \
		echo "$$CMD"; \
		eval "$$CMD"; \
	else \
		CMD="docker compose -f compose.yaml up --force-recreate --remove-orphans -d"; \
		echo "$$CMD"; \
		eval "$$CMD"; \
	fi

.PHONY: dev
dev:: compose.yaml pre-deploy
	@# Help: Run docker compose in dev mode
	@if [ -f compose.dev.yaml ]; then \
		CMD="docker compose -f compose.yaml -f compose.dev.yaml up --remove-orphans -d"; \
		echo "$$CMD"; \
		eval "$$CMD"; \
	else \
		CMD="docker compose -f compose.yaml up --remove-orphans -d"; \
		echo "$$CMD"; \
		eval "$$CMD"; \
	fi


# Install crontab if it exists (will only run if crontab file changed)
$(COMPOSE_CRONTAB): crontab
	@# Help: Install crontab file to /etc/cron.d/
	@test -d /etc/cron.d && cp $< $@

.PHONY: deploy
deploy:: compose.yaml pre-deploy
	@# Help: docker compose up
	@if [ -f crontab ]; then $(MAKE) $(COMPOSE_CRONTAB); fi
	docker compose -f compose.yaml up  --remove-orphans -d -V

.PHONY: deploy-recreate
deploy-recreate:: compose.yaml pre-deploy
	@# Help: docker compose deploy, recreating containers
	@if [ -f crontab ]; then $(MAKE) $(COMPOSE_CRONTAB); fi
	docker compose -f compose.yaml up  --remove-orphans --force-recreate -d -V

.PHONY: down
dev-down:: compose.yaml .env
	@# Help: docker compose remove
	@if [ -f compose.dev.yaml ]; then \
		CMD="docker compose -f compose.yaml -f compose.dev.yaml down --remove-orphans -v"; \
		echo "$$CMD"; \
		eval "$$CMD"; \
	else \
		CMD="docker compose -f compose.yaml down --remove-orphans -v"; \
		echo "$$CMD"; \
		eval "$$CMD"; \
	fi

.PHONY: down
down:: compose.yaml .env
	@# Help: docker compose remove
	@if [ -f crontab ]; then rm -f $(COMPOSE_CRONTAB); fi
	docker compose -f compose.yaml down --remove-orphans -v


# Generic rule to process any template file
%.yaml: %.template.yaml
	@# Help: Generate config from template
	op inject -f -i $< -o $@
