IMAGE_NAME := prefect-python
IMAGE_AGENT_NAME := prefect-python-agent
DOCKER := podman
IMAGE_TAG := 1.0
IMAGE := ${IMAGE_NAME}:${IMAGE_TAG}
IMAGE_AGENT := ${IMAGE_AGENT_NAME}:${IMAGE_TAG}
IMAGE_HASH := $(shell command docker images -q ${IMAGE} 2> /dev/null)

 
.PHONY: docker_image_cond
docker_image_cond:
ifeq ($(IMAGE_HASH),)
docker_image_cond: docker 
endif


.PHONY: docker
docker:
	@echo "building docker image ...";
	${DOCKER} build --no-cache -f Dockerfile -t ${IMAGE} .

.PHONY: docker-agent
docker-agent:
	@echo "building docker image ...";
	${DOCKER} build -f Dockerfile-agent -t ${IMAGE_AGENT} .
