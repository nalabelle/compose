include ../compose.mk

COMPOSE_CRONTAB := /etc/cron.d/compose-media

${COMPOSE_CRONTAB}: crontab
	@# Help: Create ${COMPOSE_CRONTAB}
	@test -d /etc/cron.d && cp crontab ${COMPOSE_CRONTAB}

down::
	rm -f ${COMPOSE_CRONTAB}

deploy:: ${COMPOSE_CRONTAB}
deploy-recreate:: ${COMPOSE_CRONTAB}
