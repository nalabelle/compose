include compose.mk

.PHONY: lint-ci
lint-ci:
	@# Help: Run all linters in CI mode
	pre-commit run --all-files

.PHONY: deploy
deploy::
	@true

.PHONY: docker-clean
.ONESHELL: docker-clean
docker-clean:
	@# Help: Not included in normal clean, removes all docker containers
	@[ -n "$$(docker ps -aq)" ] || { echo "No containers to remove" && exit 0; }
	@docker ps -aq | xargs docker stop | xargs docker rm
	@docker system prune -af
	@docker volume prune -af
	@docker image prune -f

.PHONY: docker-prune
docker-prune:
	@# Help: Clean unused resources from docker
# I'm not sure if -af --volumes does the same thing as running each of these?
	@docker system prune -af
	@docker volume prune -f

.git/hooks/post-update: .hooks/post-update
	@# Help: Install git post-update hook to make this a push target
	git config pull.rebase true
	git config receive.denyCurrentBranch updateInstead
	ln -s ../../$< $@
