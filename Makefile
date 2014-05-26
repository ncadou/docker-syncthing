VOLUMES ?= /srv/docker/volumes
IMAGE ?= ncadou/syncthing
CONTAINER ?= syncthing

ifdef INSTANCE
CONTAINER := $(CONTAINER)-$(INSTANCE)
endif

HOSTNAME ?= $(CONTAINER)

VOLUME_CONF_GUEST = /home/syncthing/.config/syncthing
VOLUME_DATA_GUEST = /home/syncthing/Sync
VOLUME_CONF_HOST ?= $(VOLUMES)/$(CONTAINER)/config
VOLUME_DATA_HOST ?= $(VOLUMES)/$(CONTAINER)/data
VOLUME_DIRS_HOST = $(VOLUME_CONF_HOST) $(VOLUME_DATA_HOST)

VOLUME_OPTS = -v $(VOLUME_CONF_HOST):$(VOLUME_CONF_GUEST) \
              -v $(VOLUME_DATA_HOST):$(VOLUME_DATA_GUEST)

NETWORK_OPTS := -p 8080:8080 \
                -p 22000:22000 \
                -p 21025:21025/udp

OPTIONS = -h $(HOSTNAME) $(VOLUME_OPTS) $(NETWORK_OPTS)

USERID ?= 1000
GROUPID ?= 1000

.PHONY: build clear-flag logs restart rm rmi setup-volumes shell start stop tail

clear-flag:
	-rm .$(FLAG)

start stop restart logs rm:
	docker $@ $(CONTAINER)

build: .build
.build: Dockerfile
	docker build --rm -t $(IMAGE) .
	touch .build

rmi: FLAG = build
rmi: clear-flag
	docker rmi $(IMAGE)

setup-volumes: $(VOLUME_DIRS_HOST)
$(VOLUME_DIRS_HOST):
	mkdir -p "$@"
	chmod -R g-w,o-rwx "$@"
	chown -R $(USERID):$(GROUPID) "$@"

shell: build setup-volumes Makefile
	docker run --rm -i -t $(OPTIONS) $(IMAGE) bash

run: .run
.run: build setup-volumes Makefile
	docker run -d --name $(CONTAINER) $(OPTIONS) $(IMAGE)
	touch .run

rm: FLAG = run
rm: clear-flag

tail:
	docker logs -f $(CONTAINER)
