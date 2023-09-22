APP_BIN?=app

.PHONY: default
default: build

DOCKER_REPO?=klqi/ocean_215-image
DOCKER_TAG?=latest

build:
	docker build -t $(DOCKER_REPO):$(DOCKER_TAG) .

push: build
	docker push $(DOCKER_REPO):$(DOCKER_TAG)
