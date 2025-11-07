include .env

BIN ?= api

# Used internally.  Users should pass GOOS and/or GOARCH.
OS := $(if $(GOOS),$(GOOS),$(shell GOTOOLCHAIN=local go env GOOS))
ARCH := $(if $(GOARCH),$(GOARCH),$(shell GOTOOLCHAIN=local go env GOARCH))
GO := $(if $(GOVERSION),$(GOVERSION),$(shell GOTOOLCHAIN=local go env GOVERSION))

SHELL := /usr/bin/env bash -o errexit -o pipefail -o nounset
GOFLAGS ?=

# VERSION ?= $(shell git describe --tags --always --dirty)
VERSION ?= 1.0.0

REGISTRY ?= localhost:5000
IMAGE_NAME ?= hello-api
IMAGE_TAG ?= $(VERSION)
IMAGE ?= $(IMAGE_NAME)-$(IMAGE_TAG)

all: # @HELP build container image 
all: image 

build: # @HELP build app for local development
build: deps lint test 
	mkdir -p bin
	GOOS=${OS} GOARCH=${ARCH} go build -o bin/$(BIN) $(GOFLAGS) ./cmd/api/main.go

clean: # @HELP clean build artifacts
clean: image-clean
	rm -rf ./bin

docs: # @HELP generate documentation
docs:
	swag init -g ./cmd/api/main.go -o ./api/swagger

deps: # @HELP go mod tidy, download
deps:
	go mod tidy
	go mod download

image: # @HELP builds docker image
image:
	@docker image inspect $(IMAGE) >/dev/null 2>&1 \
		&& echo "Image $(IMAGE) already exists." \
		|| docker build -t $(IMAGE) .


image-clean:
	docker rmi $(IMAGE) || true

push: image-push

image-push: # @HELP pushes image to $(REGISTRY)
image-push:
	docker tag $(IMAGE) $(REGISTRY)/$(IMAGE)
	docker push $(REGISTRY)/$(IMAGE)
	curl -k '$(REGISTRY)/v2/_catalog'

lint: # @HELP lint with golangci-lint
lint:
	golangci-lint run

test: # @HELP runs unit tests
test:
	go test ./...

version: # @HELP prints the version string
version:
	@echo $(VERSION)

help: # @HELP prints this message
help:
	echo "VARIABLES:"
	echo "  BIN = $(BIN)"
	echo "  OS = $(OS)"
	echo "  ARCH = $(ARCH)"
	echo "  GOFLAGS = $(GOFLAGS)"
	echo "  GO = $(GO)"
	echo "  IMAGE = $(IMAGE)"
	echo "  REGISTRY = $(REGISTRY)"
	echo
	echo "TARGETS:"
	grep -E '^.*: *# *@HELP' $(MAKEFILE_LIST)     \
	    | awk '                                   \
	        BEGIN {FS = ": *# *@HELP"};           \
	        { printf "  %-30s %s\n", $$1, $$2 };  \
	    '

.SILENT: help
.PHONY: all build clean image image-clean test help
