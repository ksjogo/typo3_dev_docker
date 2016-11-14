ifeq ($(shell uname),Darwin)
	XDEBUG_CONFIG = "idekey=mac remote_host=$(shell ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $$2}')"
else
	XDEBUG_CONFIG = "idekey=linux fixme"
endif

# If the first argument is one of the supported commands...
SUPPORTED_COMMANDS := console
SUPPORTS_MAKE_ARGS := $(findstring $(firstword $(MAKECMDGOALS)), $(SUPPORTED_COMMANDS))
ifneq "$(SUPPORTS_MAKE_ARGS)" ""
  # use the rest as arguments for the command
  COMMAND_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
endif
# ...and turn them into do-nothing targets
%:
	@:

buildtypo3: ##build up-to-date typo3 image
	@docker-compose -f docker-compose.yml -f docker-compose.dev.yml build typo3

build: buildtypo3 ##build up-to-date docker images

console: ## Trigger Symfony script bin/command
	@export XDEBUG_CONFIG=${XDEBUG_CONFIG} && docker-compose -f docker-compose.yml -f docker-compose.dev.yml exec typo3	\
		vendor/helhum/typo3-console/Scripts/typo3cms $(COMMAND_ARGS)

typo3: buildtypo3 ## Run the typo3 instance from docker compose
	@export XDEBUG_CONFIG=${XDEBUG_CONFIG} && docker-compose -f docker-compose.yml -f docker-compose.dev.yml up typo3

typo3bash: ## Get a bash inside the typo3 instance
	@export XDEBUG_CONFIG=${XDEBUG_CONFIG} && docker-compose exec typo3 bash

typo3_prod: ## Run the typo3 instance from docker compose
	@docker-compose -f docker-compose.yml up typo3

.DEFAULT_GOAL := typo3
