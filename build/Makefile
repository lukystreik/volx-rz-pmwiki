# Makefile für PmWiki-Docker-Image

# .env einbinden, falls vorhanden (z.B. IMAGENAME=repo/pmwiki:latest)
ifneq (,$(wildcard .env))
  include .env
  export
endif

# Default-Image-Name, falls in .env nichts gesetzt ist
IMAGENAME ?= pmwiki:latest

# Basisname ohne Tag
IMAGE_BASE := $(shell echo $(IMAGENAME) | sed -e 's/:.*//')

# PmWiki-Version dynamisch aus dem Web ermitteln
PMWIKI_VERSION := $(shell wget --quiet http://www.pmwiki.org/pub/pmwiki/ -O- 2>/dev/null | grep 'pmwiki-' | egrep -v 'zip|patch|md5|latest' | sed -e 's/.*pmwiki-//' -e 's/<\/a.*//' -e 's/.tgz.*//' | sort -V | tail -1)

# Fallback, falls leer
ifeq ($(PMWIKI_VERSION),)
  PMWIKI_VERSION := latest
endif

STAMP := $(shell date '+%Y%m%d%H%M')

.PHONY: help build scan push all run shell tags

help:
	@echo "Makefile-Befehle:"
	@echo "  make build   - Docker-Image bauen (tags: $(IMAGENAME), $(IMAGE_BASE):$(PMWIKI_VERSION))"
	@echo "  make scan    - Trivy-Scan des Images"
	@echo "  make push    - docker push für beide Tags"
	@echo "  make all     - build + scan + push"
	@echo "  make run     - lokalen Container starten (Port 8080->80)"
	@echo "  make shell   - Shell im Container starten"
	@echo "Aktuelle PmWiki-Version: $(PMWIKI_VERSION)"

build:
	@echo "Baue Image:"
	@echo "  IMAGENAME       = $(IMAGENAME)"
	@echo "  IMAGE_BASE      = $(IMAGE_BASE)"
	@echo "  PMWIKI_VERSION  = $(PMWIKI_VERSION)"
	DOCKER_BUILDKIT=1 docker build \
		-t $(IMAGENAME) \
		-t $(IMAGE_BASE):$(PMWIKI_VERSION) \
		.

scan:
	@echo "Trivy-Scan für $(IMAGENAME)"
	trivy image $(IMAGENAME) > trivy-scanresult-$(STAMP).txt
	@echo "Scan-Report: trivy-scanresult-$(STAMP).txt"

push:
	@echo "Push $(IMAGENAME)"
	docker push $(IMAGENAME)
	@echo "Push $(IMAGE_BASE):$(PMWIKI_VERSION)"
	docker push $(IMAGE_BASE):$(PMWIKI_VERSION)
	@if command -v docker-pushrm >/dev/null 2>&1; then \
	  echo "docker-pushrm $(IMAGENAME)"; \
	  docker pushrm $(IMAGENAME) || true; \
	fi

all: build scan push

run:
	@echo "Starte Container lokal auf Port 8080 -> 80"
	docker run --rm -it \
	  -p 8080:80 \
	  -v $(PWD)/wiki.d:/var/www/html/wiki.d \
	  -v $(PWD)/local:/var/www/html/local \
	  -v $(PWD)/cookbook:/var/www/html/cookbook \
	  -v $(PWD)/uploads:/var/www/html/uploads \
	  $(IMAGENAME)

shell:
	@echo "Starte Shell im Container"
	docker run --rm -it \
	  -p 8080:80 \
	  $(IMAGENAME) \
	  /bin/bash

