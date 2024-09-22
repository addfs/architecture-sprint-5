ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
NODE_IMAGE=node:20-slim
UID=$(shell id -u)
GID=$(shell id -g)

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
	@docker build -t rasa/rasa-custom:latest $(ROOT_DIR)/rasa

rasa-train:
	@echo "Training rasa model..."
	@docker run --rm -v $(ROOT_DIR)/rasa:/app -u $(UID):$(GID) -w /app rasa/rasa-custom:latest train

