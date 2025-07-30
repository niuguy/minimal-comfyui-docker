# Minimal ComfyUI Docker Makefile

# Configuration
REGISTRY ?= docker.io
REGISTRY_USER ?= your-username
APP ?= comfyui-minimal
VERSION ?= v0.3.47

# Build targets
.PHONY: build push run clean help

build: ## Build the Docker image
	docker buildx bake

build-all: ## Build all variants
	docker buildx bake all

push: ## Build and push to registry
	REGISTRY=$(REGISTRY) REGISTRY_USER=$(REGISTRY_USER) docker buildx bake --push

run: ## Run locally for testing
	docker run -d --gpus all --name $(APP)-test -p 8080:80 $(REGISTRY_USER)/$(APP):latest

stop: ## Stop local test container
	docker stop $(APP)-test || true
	docker rm $(APP)-test || true

clean: ## Clean up local images and containers
	docker stop $(APP)-test || true
	docker rm $(APP)-test || true
	docker rmi $(REGISTRY_USER)/$(APP):latest || true

logs: ## Show logs from test container
	docker logs -f $(APP)-test

shell: ## Get shell access to test container
	docker exec -it $(APP)-test /bin/bash

health: ## Check health of test container
	curl -f http://localhost:8080/health

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)