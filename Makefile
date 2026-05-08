IMAGE ?= stash-filemonitor:local
CONTAINER ?= stash-filemonitor
STASH_URL ?= http://127.0.0.1:9999
STASH_API_KEY ?=
PLUGIN_DIR ?= /mnt/user/appdata/stash/plugins/community/filemonitor
MEDIA_HOST_PATH ?= /mnt/user/Media
MEDIA_CONTAINER_PATH ?= /data
FILEMONITOR_DOCKER_CONFIG ?=

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
		-v "$(PLUGIN_DIR):/filemonitor:ro" \
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
		-v "$(PLUGIN_DIR):/filemonitor:ro" \
		-v "$(MEDIA_HOST_PATH):$(MEDIA_CONTAINER_PATH):ro" \
		$(IMAGE) sh
