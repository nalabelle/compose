include ../compose.mk

# List all output files that will be generated from templates
TEMPLATE_TARGETS := scrape-configs.yaml

clean::
	rm -f $(TEMPLATE_TARGETS)

# Make pre-deploy depend on all template targets
pre-deploy:: $(TEMPLATE_TARGETS)
