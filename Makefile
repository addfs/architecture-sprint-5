ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
NODE_IMAGE=node:20-slim
UID=$(shell id -u)
GID=$(shell id -g)
GITHUB_PERSONAL_ACCESS_TOKEN=
GITHUB_DOCKER_IMAGE=ghcr.io/addfs/rasa

deps:
	@echo "Installing frontend dependencies..."
	@docker run --rm -v $(ROOT_DIR)/frontend:/app -u $(UID):$(GID) -w /app $(NODE_IMAGE) npm install

start: deps
	@docker compose up -d --build

rasa-init:
	@echo "init rasa"
	@docker run --rm -v $(ROOT_DIR)/rasa:/app -u $(UID):$(GID) -w /app rasa/rasa:3.6.20-full init --no-prompt

rasa-build:
	@echo "Building rasa image..."
	@docker build -t $(GITHUB_DOCKER_IMAGE)/rasa-custom:latest $(ROOT_DIR)/rasa

rasa-train:
	@echo "Training rasa model..."
	@rm -r $(ROOT_DIR)/rasa/.rasa/cache
	@docker run --rm -v $(ROOT_DIR)/rasa:/app -u $(UID):$(GID) -w /app $(GITHUB_DOCKER_IMAGE)/rasa-custom:latest train

frontend-build:
	@echo "Building frontend..."
	@docker build -t $(GITHUB_DOCKER_IMAGE)/frontend:latest $(ROOT_DIR)/frontend

docker-login:
	@echo "Logging in to docker hub..."
	@echo $(GITHUB_PERSONAL_ACCESS_TOKEN) | docker login ghcr.io -u addfs --password-stdin

docker-push:
	@echo "Pushing images to docker hub..."
	@docker push ghcr.io/addfs/rasa/frontend:latest
	@docker push ghcr.io/addfs/rasa/rasa-custom:latest

rasa-retrain: rasa-build rasa-train
	@echo "Restarting rasa..."
	@docker compose up -d --build rasa