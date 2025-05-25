SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

.DEFAULT_GOAL:=help

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

.PHONY: secrets
secrets::
	@# Help: Load secrets from 1password - to be overriden by specific Makefiles
	@true

.env: .env.tpl $(wildcard .env.local)
	@# Help: Load secrets from 1password
	@HOSTNAME=$${HOSTNAME:-$$(hostname)} && \
	op inject -f -i .env.tpl -o .env && \
	{ test -f .env.local && echo "" && echo "# LOCAL OVERRIDES" && cat .env.local; true; } >> .env

.PHONY: pull
pull: compose.yaml .env
	@# Help: docker compose pull
	docker compose -f $< pull

.PHONY: dev-recreate
dev-recreate: compose.yaml .env secrets
	@# Help: Run docker compose in dev mode, recreating containers
	@if [ -f compose.dev.yaml ]; then \
		docker compose -f compose.yaml -f compose.dev.yaml up --force-recreate --remove-orphans -d; \
	else \
		docker compose -f compose.yaml up --force-recreate --remove-orphans -d; \
	fi

.PHONY: dev
dev: compose.yaml .env secrets
	@# Help: Run docker compose in dev mode
	@if [ -f compose.dev.yaml ]; then \
		docker compose -f compose.yaml -f compose.dev.yaml up --remove-orphans -d; \
	else \
		docker compose -f compose.yaml up --remove-orphans -d; \
	fi

.PHONY: deploy
deploy: compose.yaml .env secrets
	@# Help: docker compose up
	docker compose -f $< up  --remove-orphans -d

.PHONY: deploy-recreate
deploy-recreate: compose.yaml .env secrets
	@# Help: docker compose deploy, recreating containers
	docker compose -f $< up  --remove-orphans --force-recreate -d

.PHONY: down
down: compose.yaml .env
	@# Help: docker compose remove
	docker compose down --remove-orphans


# Generic rule to process any template file
%.yaml: %.template.yaml
	@# Help: Generate config from template
	op inject -f -i $< -o $@
