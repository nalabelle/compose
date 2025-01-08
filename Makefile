SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

HOSTNAME:=$(shell hostname)
COMPOSE_STACKS := $(patsubst compose.%.yaml,%, $(wildcard compose.*.yaml))
SECRET_SOURCES := $(shell find secrets -type f -print)

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

node_modules: package.json
	npm ci
	touch $@

.PHONY: lintfix
lintfix: node_modules lint-ci
	@# Help: Run all linters
	@echo "Running dclint..."
	@npx dclint . --recursive --fix --exclude .devbox volumes .cache _secrets
	@echo "Done"

.PHONY: lint-ci
lint-ci:
	@# Help: Run all linters in CI mode
	SKIP=lintfix pre-commit run --all-files

.PHONY: deploy
deploy:
	@# Help: Deploy all compose projects
	@bin/deploy

.PHONY: docker-clean
.ONESHELL: docker-clean
docker-clean:
	@# Help: Not included in normal clean, removes all docker containers
	@[ -n "$$(docker ps -aq)" ] || { echo "No containers to remove" && exit 0; }
	@docker ps -aq | xargs docker stop | xargs docker rm


.PHONY: docker-prune
docker-prune:
	@# Help: Clean unused resources from docker
# I'm not sure if -af --volumes does the same thing as running each of these?
	@docker system prune -af
	@docker volume prune -f

.PHONY: clean
clean: clean-secrets
	@# Help: Remove all generated files

.git/hooks/post-update: .hooks/post-update
	@# Help: Install git post-update hook to make this a push target
	git config pull.rebase true
	git config receive.denyCurrentBranch updateInstead
	ln -s ../../$< $@

.PHONY: secrets clean-secrets
secrets:  _secrets .env
	@# Help: Load secrets from 1password
	@true
clean-secrets:
	@# Help: Remove generated secrets
	@rm .env
	@rm -rf _secrets

_secrets/%: secrets/%
	@mkdir -p $(dir $@)
	@printf '%s < %s\n' $@ $<
	@envsubst < <(op inject -i .env.tpl) > $@
	@HOSTNAME=$(HOSTNAME) \
		envsubst < <(op inject -f -i $<) > $@ 2>/dev/null && chmod 644 $@

.env: .env.tpl $(wildcard .env.local)
	@# Help: Create .env file with secrets from .env.tpl
	@envsubst < <(op inject -i .env.tpl) > $@
	@{ test -f .env.local \
		&& echo "" >> $@ \
		&& echo "# LOCAL OVERRIDES" >> $@ \
		&& cat .env.local >> $@; } \
		|| true
	@echo "HOSTNAME=$(HOSTNAME)" >> $@

define genComposeTargets
_secrets/$(1)/common/%: secrets/common/%
	@mkdir -p $$(dir $$@)
	@printf '%s < %s\n' $$@ $$<
	@COMPOSE_PROJECT_NAME=$(1) HOSTNAME=$$(HOSTNAME) op inject -f -i $$< -o $$@ > /dev/null && chmod 644 $$@

_secrets/$(1): $$(patsubst secrets/%, _secrets/%, $$(filter secrets/$(1)/%,$$(SECRET_SOURCES))) \
		$$(patsubst secrets/%, _secrets/$(1)/%, $$(filter secrets/common/%,$$(SECRET_SOURCES)))
	@# Help: Create secrets for $(1)
	@true

.PHONY: $(1)-deploy $(1)-down $(1)-pull
$(1)-deploy: compose.$(1).yaml _secrets/$(1) .env
	@# Help: docker compose deploy $(1)
	docker compose -f $$< up -d --remove-orphans --force-recreate

$(1)-pull: compose.$(1).yaml _secrets/$(1) .env
	@# Help: docker compose pull $(1)
	docker compose -f $$< pull

$(1)-down: compose.$(1).yaml .env
	@# Help: docker compose remove $(1)
	docker compose -f $$< down
endef

$(foreach compose_stack,$(COMPOSE_STACKS),$(eval $(call genComposeTargets,$(compose_stack))))
