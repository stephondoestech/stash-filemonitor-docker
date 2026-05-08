ifneq (,$(wildcard .env))
include .env
export
endif

IMAGE ?= stash-filemonitor:local
CONTAINER ?= stash-filemonitor
STASH_URL ?=
STASH_API_KEY ?=
PLUGIN_DIR ?= /mnt/user/appdata/stash/plugins/community/filemonitor
MEDIA_HOST_PATH ?= /mnt/user/Media
MEDIA_CONTAINER_PATH ?= /data
FILEMONITOR_DOCKER_CONFIG ?=
FILEMONITOR_TRACE ?= false

.PHONY: build run logs stop rm restart shell

build:
	docker build -t $(IMAGE) .

run:
	docker run -d \
		--name $(CONTAINER) \
		--restart unless-stopped \
		--network host \
		-e STASH_URL="$(STASH_URL)" \
		-e STASH_API_KEY="$(STASH_API_KEY)" \
		-e FILEMONITOR_DOCKER_CONFIG="$(FILEMONITOR_DOCKER_CONFIG)" \
		-e FILEMONITOR_TRACE="$(FILEMONITOR_TRACE)" \
		-v "$(PLUGIN_DIR):/filemonitor:rw" \
		-v "$(MEDIA_HOST_PATH):$(MEDIA_CONTAINER_PATH):ro" \
		$(IMAGE)

logs:
	docker logs -f $(CONTAINER)

stop:
	docker stop $(CONTAINER)

rm:
	docker rm $(CONTAINER)

restart: stop rm run

shell:
	docker run --rm -it \
		--network host \
		-e STASH_URL="$(STASH_URL)" \
		-e STASH_API_KEY="$(STASH_API_KEY)" \
		-e FILEMONITOR_DOCKER_CONFIG="$(FILEMONITOR_DOCKER_CONFIG)" \
		-e FILEMONITOR_TRACE="$(FILEMONITOR_TRACE)" \
		-v "$(PLUGIN_DIR):/filemonitor:rw" \
		-v "$(MEDIA_HOST_PATH):$(MEDIA_CONTAINER_PATH):ro" \
		$(IMAGE) sh
