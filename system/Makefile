include ../compose.mk

/etc/cron.d/compose-system:
	@# Help: Create /etc/cron.d/compose-system
	@test -d /etc/cron.d && cp crontab /etc/cron.d/compose-system

down::
	rm -f /etc/cron.d/compose-system

deploy:: /etc/cron.d/compose-system

deploy-recreate:: /etc/cron.d/compose-system
