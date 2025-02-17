IMAGE_NAME=awendt/all-in-one
PLATFORMS=linux/amd64,linux/arm64

# Extract the version from the Dockerfile
VERSION=$(shell awk -F= '/ARG VERSION/ {print $$2}' Dockerfile | tr -d ' ')

.PHONY: build push create-builder delete-builder

# Build ONLY for the local architecture (not multi-arch)
build:
	docker buildx build --platform=linux/$(shell uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/') --build-arg VERSION=$(VERSION) --label "org.opencontainers.image.version=$(VERSION)" -t $(IMAGE_NAME):$(VERSION) --load .
	docker tag $(IMAGE_NAME):$(VERSION) $(IMAGE_NAME):latest

# Multi-architecture build for a registry (direct push, no local image)
push:
	docker buildx build --platform $(PLATFORMS) --build-arg VERSION=$(VERSION) --label "org.opencontainers.image.version=$(VERSION)" -t $(IMAGE_NAME):$(VERSION) --push .
	docker buildx imagetools create -t $(IMAGE_NAME):latest $(IMAGE_NAME):$(VERSION)

create-builder:
	docker buildx inspect multiarch-builder >/dev/null 2>&1 || docker buildx create --name multiarch-builder --use
	docker buildx inspect --bootstrap

delete-builder:
	docker buildx rm multiarch-builder || true
