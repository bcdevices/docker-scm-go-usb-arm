# Makefile
PRJ_TAG := scm-go-usb
default: all
INSTALL_ROOT ?= /opt/$(PRJ_TAG)
DIST_PATH = $(realpath .)/dist
GIT_DESC := $(shell git describe --tags --always --dirty --match "v[0-9]*")
VERSION_TAG ?= $(patsubst v%,%,$(GIT_DESC))
VERSION_TAG ?= unknown
#DUMP_VARS = y
#SHOW_PASS = y
#VERBOSE ?= y
ifneq ($(VERBOSE),)
  DUMP_VARS = y
  SHOW_PASS = y
endif
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
  DOCKER_UID = 1000
  DOCKER_GID = 1000
endif
CC ?= gcc
TARGET_ARCHS :=
TARGET_ARCHS += host
TARGET_ARCHS += linux-amd64
TARGET_ARCHS += linux-arm64
ifneq ($(TARGET_ARCH),)
  ifeq ($(filter $(TARGET_ARCH),$(TARGET_ARCHS)),)
    $(error "Invalid TARGET_ARCH: $(TARGET_ARCH), not in: $(TARGET_ARCHS)")
  endif
endif
GCCTRIPLET_linux-amd64 := x86_64-linux-gnu
GCCTRIPLET_linux-arm64 := aarch64-linux-gnu
GCCTRIPLETS :=
GCCTRIPLETS += $(GCCTRIPLET_linux-amd64)
GCCTRIPLETS += $(GCCTRIPLET_linux-arm64)
GCCTRIPLET_CROSS ?= $(GCCTRIPLET_$(TARGET_ARCH))
ifneq ($(GCCTRIPLET_CROSS),)
  ifeq ($(filter $(GCCTRIPLET_CROSS),$(GCCTRIPLETS)),)
    $(error "Invalid GCCTRIPLET_CROSS: $(GCCTRIPLET_CROSS), not in: $(GCCTRIPLETS)")
  endif
endif
CC_CROSS ?= $(GCCTRIPLET_CROSS)-gcc
PKG_CONFIG_SYSROOT_DIR_CROSS ?=
PKG_CONFIG_LIBDIR_CROSS ?= /usr/lib/$(GCCTRIPLET_CROSS)/pkgconfig:/usr/share/pkgconfig
GO ?= go
GOFMT ?= gofmt
GO_BUILD_OPTS :=
GO_BUILD_OPTS += -buildvcs=false
#GO_BUILD_OPTS += -mod vendor
CGO_ENABLED ?= 1
GO_BUILD ?= CC=$(CC) CGO_ENABLED=$(CGO_ENABLED) $(GO) build $(GO_BUILD_OPTS)
GO_TEST ?= CC=$(CC) CGO_ENABLED=$(CGO_ENABLED) $(GO) test $(GO_BUILD_OPTS)
GOARCH_linux-amd64 := amd64
GOARCH_linux-arm64 := arm64
GOARCH_CROSS ?= $(GOARCH_$(TARGET_ARCH))
GOARM_CROSS ?= 7
GOOS_CROSS := linux
CGO_CFLAGS_CROSS ?= 
CGO_LDFLAGS_CROSS ?=
GO_BUILD_CROSS ?= CC=$(CC_CROSS) CGO_ENABLED=$(CGO_ENABLED) CGO_CFLAGS=$(CGO_CFLAGS_CROSS) CGO_LDFLAGS=$(CGO_LDFLAGS_CROSS) GOOS=$(GOOS_CROSS) GOARCH=$(GOARCH_CROSS) GOARM=$(GOARM_CROSS) PKG_CONFIG_LIBDIR=$(PKG_CONFIG_LIBDIR_CROSS) PKG_CONFIG_SYSROOT_DIR=$(PKG_CONFIG_SYSROOT_DIR_CROSS) $(GO) build $(GO_BUILD_OPTS)
build/bin/%:
	$(GO_BUILD) -o $@ ./cmd/$*
build/$(TARGET_ARCH)/bin/%:
	$(GO_BUILD_CROSS) -o $@ ./cmd/$*
BINS_amd64 :=
BINS_amd64 += build/linux-amd64/bin/deps
BINS_arm64 :=
BINS_arm64 += build/linux-arm64/bin/deps
BINS_host :=
BINS_host += build/bin/deps
INSTALL_FILES :=
INSTALL_FILES += $(INSTALL_ROOT)/bin/deps
BINS :=
ifeq ($(TARGET_ARCH),)
  BINS += $(BINS_host)
endif
ifeq ($(TARGET_ARCH),linux-arm64)
  BINS += $(BINS_arm64)
endif
ifeq ($(TARGET_ARCH),linux-amd64)
  BINS += $(BINS_amd64)
endif
TOOL_VERSION_elixir=$(shell grep "^elixir " .tool-versions | cut -d" " -f2)
TOOL_VERSION_golang=$(shell grep "^golang " .tool-versions | cut -d" " -f2)
TOOL_VERSION_golangci-lint=$(shell grep "^golangci-lint " .tool-versions | cut -d" " -f2)
TOOL_VERSION_nerves-system-br=$(shell grep "^nerves-system-br " .tool-versions | cut -d" " -f2)
TOOL_VERSION_reviewdog=$(shell grep "^reviewdog " .tool-versions | cut -d" " -f2)
TOOL_VERSION_scm_go_usb="2"
VERSION_ERRORS = $(shell find . -name "Dockerfile" -exec \
	 	grep -H "ARG .*_VERSION=" \{\} \; | \
		grep -v "ARG GOUSB_VERSION=\"${TOOL_VERSION_scm_go_usb}\"" | \
		grep -v "ARG ELIXIR_VERSION=\"${TOOL_VERSION_elixir}\"" | \
		grep -v "ARG GOLANG_VERSION=\"${TOOL_VERSION_golang}\"" | \
		grep -v "ARG GOLANGCI_LINT_VERSION=\"${TOOL_VERSION_golangci-lint}\"" | \
		grep -v "ARG NERVES_SYSTEM_BR_VERSION=\"${TOOL_VERSION_nerves-system-br}\"" | \
		grep -v "ARG REVIEWDOG_VERSION=\"${TOOL_VERSION_reviewdog}\"")
.PHONY: tool-versions-dump
tool-versions-dump:
.PHONY: hadolint
hadolint:
	@find . -name Dockerfile -exec hadolint \{\} \;
check-tool-versions:
	@if [ ! -z "${VERSION_ERRORS}" ]; then \
		echo "Mismatched versions:" ; \
	       	echo "${VERSION_ERRORS}"; \
	       	exit -1; \
	fi
.PHONY: check-common
check-common: check-tool-versions
.PHONY: check-host-compile
check-host-compile: check-common
.PHONY: check-cross-compile
check-cross-compile: check-common
.PHONY: check-install-host
check-install-host: check-common
.PHONY: check-build-host
check-build-host: check-host-compile check-cross-compile
.PHONY: check-test-host
check-test-host: check-host-compile
.PHONY: all
all: check-build-host $(BINS)
.PHONY: install
install: check-install-host $(INSTALL_FILES)
INSTALL_BINDIR ?= $(INSTALL_ROOT)/bin
INSTALL_BINDIR_CROSS ?= $(INSTALL_ROOT)/$(TARGET_ARCH)/bin
$(INSTALL_BINDIR):
	@mkdir -p $@
$(INSTALL_BINDIR_CROSS):
	@mkdir -p $@
$(INSTALL_BINDIR)/%: $(INSTALL_BINDIR) $(BINS)
	install -v build/bin/$* $@
$(INSTALL_BINDIR_CROSS)/%: $(INSTALL_BINDIR_CROSS) $(BINS)
	install -v build/$(TARGET_ARCH)/bin/$* $@
.PHONY: uninstall
uninstall:
	@rm -f $(INSTALL_FILES)
.PHONY: clean
clean:
	-rm -rf ./build
.PHONY: dist-archive
dist-archive:
	-mkdir -p $(DIST_PATH)
	cd build && zip -r \
		$(DIST_PATH)/$(PRJ_TAG)-$(VERSION_TAG).zip .
.PHONY: dist
dist: all dist-archive
.PHONY: distclean
distclean: clean
	-rm -rf ./dist
.PHONY: test
test: check-test-host
	$(GO_TEST) ./...
GO_SRC_FILES = $(shell find . -type f -name '*.go' -not -path "./vendor/*")
.PHONY: lint-format
lint-format:
	@$(GOFMT) -s -d $(GO_SRC_FILES) | read \
	&& echo "non-standard formatting (use gofmt -w -s)" 1>&2 \
	&& exit 1 || true
GOLANGCI_LINT ?= golangci-lint
.PHONY: lint-golangci
lint-golangci:
	$(GOLANGCI_LINT) run
.PHONY: lint
lint: lint-format lint-golangci
DOCKER_UID ?= $(shell id -u)
DOCKER_GID ?= $(shell id -g)
#DOCKER_LOG_LEVEL=debug
#DOCKER_LOG_LEVEL=info
DOCKER_LOG_LEVEL=warn
#DOCKER_LOG_LEVEL=error
#DOCKER_LOG_LEVEL=fatal
DOCKER_ARGS :=
DOCKER_ARGS += --log-level $(DOCKER_LOG_LEVEL)
DOCKER_BUILD_ARGS :=
DOCKER_BUILD_ARGS += --build-arg GOLANG_VERSION=$(TOOL_VERSION_golang)
DOCKER_BUILD_ARGS += --build-arg GOLANG_HOSTOS="bullseye"
DOCKER_BUILD_ARGS += --build-arg USER_UID=$(DOCKER_UID)
DOCKER_BUILD_ARGS += --build-arg USER_GID=$(DOCKER_GID)
#DOCKER_BUILD_ARGS += --no-cache
#DOCKER_BUILD_ARGS += --progress=plain
DOCKER_BUILD_ARGS += --quiet
DOCKER_RUN_ARGS :=
DOCKER_RUN_ARGS += --user=$(DOCKER_UID):$(DOCKER_GID)
DOCKER_RUN_ARGS += --net=none
DOCKER_RUN_ARGS += -v "$(PWD)":/usr/src -w /usr/src
DOCKER_GUEST_OS := jammy-scm
DOCKER_TAG_BASE := $(PRJ_TAG)-$(DOCKER_GUEST_OS)
DOCKER_NAME_BASE := $(PRJ_TAG)
.PHONY: check-docker-host
check-docker-host:
.PHONY: check-docker-guest
check-docker-guest:
.PHONY: docker-guest
docker-guest: check-docker-guest all
.PHONY: docker-%
docker-%: check-docker-host
	@docker $(DOCKER_ARGS) build \
		-t "$(DOCKER_TAG_BASE)-$*" \
	       	--build-arg TARGET_ARCH="$*" \
		$(DOCKER_BUILD_ARGS) .
	@docker rm -f "$(DOCKER_NAME_BASE)-$*" 2>/dev/null
	@docker $(DOCKER_ARGS) run \
		--rm \
		--name "$(DOCKER_NAME_BASE)-$*" \
		$(DOCKER_RUN_ARGS) \
		-t "$(DOCKER_TAG_BASE)-$*" \
		/bin/bash -c "TARGET_ARCH=linux-$* VERBOSE=$(VERBOSE) make docker-guest"
.PHONY: docker
docker: docker-amd64 docker-arm64
