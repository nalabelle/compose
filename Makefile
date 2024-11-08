SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
print-%: ; @echo $*=$($*)

SECRET_TARGETS := \
	apps/miniflux/database_url \
	common/kopia/password \
	common/kopia/server-url \
	common/postgres/password \
	common/proxy/cf_dns_api_token \
	common/proxy/cf_zone_api_token \
	media/exporter/bazarr-api-key \
	media/exporter/lidarr-api-key \
	media/exporter/prowlarr-api-key \
	media/exporter/radarr-api-key \
	media/exporter/sabnzbd-api-key \
	media/exporter/sonarr-api-key \
	services/discord-bot/discord_api_token \
	services/discord-bot/forecast_api_key \
	services/discord-bot/google_api_key \
	services/discord-bot/google_client_id \
	services/discord-bot/google_client_secret

SECRET_TEMPLATE_TARGETS := \
	apps/miniflux-sidekick.env \
	apps/wallabag.env \
	apps/alertmanager/config.yaml \
	home-automation/alertmanager/config.yaml \
	media/alertmanager/config.yaml

HOSTNAME:=$(shell hostname)
COMPOSE_SOURCES := $(wildcard compose.*.yaml)
COMPOSE_STACKS := $(patsubst compose.%.yaml,%, $(COMPOSE_SOURCES))
COMPOSE_TARGETS := $(patsubst %,%-deploy, $(COMPOSE_STACKS))
COMPOSE_TARGETS_DOWN := $(patsubst %,%-down, $(COMPOSE_STACKS))
OUTPUT_SECRET_TARGETS := $(addprefix _secrets/, $(SECRET_TARGETS))
OUTPUT_SECRET_TEMPLATE_TARGETS := $(addprefix _secrets/, $(SECRET_TEMPLATE_TARGETS))


.DEFAULT_GOAL:=help
.PHONY: help
help:
	grep -E '^[/.a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: clean
clean: clean-secrets ## Remove all generated files

.git/hooks/post-update: .hooks/post-update ## Install git post-update hook to make this a push target
	git config receive.denyCurrentBranch updateInstead
	ln -s ../../$< $@

.PHONY: secrets clean-secrets
secrets:  _secrets .env ## Load secrets from 1password
	@true
clean-secrets:
	@rm .env
	@rm -rf _secrets

_secrets: $(OUTPUT_SECRET_TARGETS) $(OUTPUT_SECRET_TEMPLATE_TARGETS) .env
$(OUTPUT_SECRET_TARGETS):
	@$(eval $@_PATH = op://Applications/$(notdir $(patsubst %/,%,$(basename $(dir $(dir $@)))))/$(notdir $@))
	@$(eval $@_PATH_SUFFIXED = op://Applications/$(notdir $(patsubst %/,%,$(basename $(dir $(dir $@)))))_$(HOSTNAME)/$(notdir $@))
	@mkdir -p $(dir $@)
	@ \
		{ op read --force --out-file $@ ${$@_PATH_SUFFIXED} > /dev/null 2>&1 \
			&& printf '%s < %s\n' $@ ${$@_PATH_SUFFIXED}; } \
		|| \
		{ op read --force --out-file $@ ${$@_PATH} > /dev/null \
			&& printf '%s < %s\n' $@ ${$@_PATH}; }
# If these are overly strict, they can't be read by the apps
	@chmod 644 $@

$(OUTPUT_SECRET_TEMPLATE_TARGETS): _secrets/%: env/%.tpl
	@mkdir -p $(dir $@)
	@op inject -f -i $< -o $@ > /dev/null
	@printf '%s < %s\n' $@ $<
# If these are overly strict, they can't be read by the apps
	@chmod 644 $@

.env: .env.tpl $(wildcard .env.local) ## Create .env file with secrets from .env.tpl
	@envsubst < <(op inject -i .env.tpl) > $@
	@{ test -f .env.local \
		&& echo "" >> $@ \
		&& echo "# LOCAL OVERRIDES" >> $@ \
		&& cat .env.local >> $@; } \
		|| true
	@echo "HOSTNAME=$$(hostname)" >> $@

.PHONY: $(COMPOSE_TARGETS)
$(COMPOSE_TARGETS): %-deploy: compose.%.yaml _secrets ## Deploy stack
	@docker compose -f $< up -d

.PHONY: $(COMPOSE_TARGETS_DOWN)
$(COMPOSE_TARGETS_DOWN): %-down: compose.%.yaml .env ## Un-deploy stack
	@docker compose -f $< down
