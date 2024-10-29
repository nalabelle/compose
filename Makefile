SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
GROOT := $(shell git rev-parse --show-toplevel 2> /dev/null)
print-%: ; @echo $*=$($*)

# List all directories except volumes
STACKS_DIRS = $(filter-out ./volumes/, $(filter %/, $(wildcard ./*/)))
# Remove the ./ and / from the directories
STACKS = $(STACKS_DIRS:./%/=%)

.PHONY: clean
clean: down
	@rm -f secrets.env

.PHONY: deploy down
deploy: .deploy
.deploy: compose.yaml */compose.yaml secrets.env
	@docker compose --env-file=secrets.env up -d;
	@date -u +"%Y-%m-%dT%H:%M:%SZ" > $@
down:
	@docker compose --env-file=secrets.env down || true;
	@rm -f .deploy

%.env: %.env.tpl
	op inject -f -i $< -o $@

%.yaml: %.yaml.tpl
	op inject -f -i $< -o $@

%.toml: %.toml.tpl
	op inject -f -i $< -o $@

.env: .env.default
	cp $< $@
