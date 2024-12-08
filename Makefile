include .env

COMPOSE_PREFIX_CMD        := COMPOSE_DOCKER_CLI_BUILD=1
COMPOSE_CMD               := docker compose
COMPOSE_FILE              := docker/docker-compose.yml
SERVICES                  := nginx ollama open-webui searxng

DOCKER_COMPOSE := $(shell if command -v docker > /dev/null && docker compose version > /dev/null 2>&1; then echo "docker compose"; elif command -v docker-compose > /dev/null; then echo "docker-compose"; else echo ""; fi)

ifeq ($(DOCKER_COMPOSE),)
$(error Docker Compose not found. Please install Docker Compose)
endif

DOCKER_COMPOSE_CMD      := ${COMPOSE_PREFIX_CMD} ${DOCKER_COMPOSE} --env-file .env
DOCKER_COMPOSE_FILE_CMD := ${DOCKER_COMPOSE_CMD} -f ${COMPOSE_FILE}

.PHONY: pull up down stop restart logs build
pull:                   ## Pull pre-built Docker images from repository.
	${DOCKER_COMPOSE_FILE_CMD} pull

build:			## Build all Docker images locally.
	${DOCKER_COMPOSE_FILE_CMD} build ${SERVICES}

up:                     ## Pull and start all services.
	@make down
	${DOCKER_COMPOSE_FILE_CMD} up -d ${SERVICES}
		
down:                   ## Down all services and remove containers.
	${DOCKER_COMPOSE_FILE_CMD} down

upgrade:
	@make down
	@make remove_images
	@make build
	@make up

stop:                   ## Stop all services.
	${DOCKER_COMPOSE_FILE_CMD} stop ${SERVICES}

restart:                   ## Restart all services.
	${DOCKER_COMPOSE_FILE_CMD} restart ${SERVICES}

logs:                   ## Tail all containers logs with -n 1000 (useful for debug).
	${DOCKER_COMPOSE_FILE_CMD} logs --follow --tail=1000 ${SERVICES}

remove_images:	## Remove all Docker images for reNgine-ng services.
	@images=$$(docker images --filter=reference='openwebui-*' --format "{{.ID}}"); \
	if [ -n "$$images" ]; then \
		echo "Removing images: $$images"; \
		docker rmi -f $$images; \
	else \
		echo "No images found for ghcr.io/security-tools-alliance/rengine-ng"; \
	fi

