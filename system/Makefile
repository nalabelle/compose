SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

HOSTNAME:=$(shell hostname)

ifneq (,$(wildcard ./.env.local))
    include .env.local
endif

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
clean:
	@# Help: Remove all generated files
	rm -f .env

.env: .env.tpl
	@# Help: Load secrets from 1password
	../bin/inject-env

.PHONY: dev
dev: compose.yaml compose.dev.yaml .env
	@# Help: Run docker compose in dev mode
	docker compose -f compose.yaml -f compose.dev.yaml up --force-recreate --remove-orphans -d

deploy: compose.yaml .env
	@# Help: docker compose deploy
	docker compose -f $< up  --remove-orphans --force-recreate -d

pull: compose.yaml .env
	@# Help: docker compose pull
	docker compose -f $$< pull

down: compose.yaml .env
	@# Help: docker compose remove
	docker compose down
