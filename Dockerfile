ARG	GOLANG_VERSION=1.20.1
FROM	golang:${GOLANG_VERSION}-bullseye
ARG	PKGS
ENV	PKGS="$(PKGS)"
ENV	PKGS="$(PKGS) unzip"
ENV	PKGS="$(PKGS) zip"

ENV	PKGS="$(PKGS) libftdi1-dev"
ENV	PKGS="$(PKGS) libusb-1.0-0-dev"
ENV	PKGS="$(PKGS) libzmq3-dev"

ENV	ARCH="arm64"
ENV	PKGS="$(PKGS) crossbuild-essential-${ARCH}"
#ENV	PKGS="$(PKGS) libftdi1-dev:${ARCH}"
ENV	PKGS="$(PKGS) libusb-1.0-0-dev:${ARCH}"
ENV	PKGS="$(PKGS) libzmq3-dev:${ARCH}"

ENV	ARCH="armhf"
ENV	PKGS="$(PKGS) crossbuild-essential-${ARCH}"
#ENV	PKGS="$(PKGS) libftdi1-dev:${ARCH}"
ENV	PKGS="$(PKGS) libusb-1.0-0-dev:${ARCH}"
ENV	PKGS="$(PKGS) libzmq3-dev:${ARCH}"

# hadolint ignore=DL3008,SC2046
RUN	apt-get update \
	&& dpkg --add-architecture arm64 \
	&& dpkg --add-architecture armhf \
	&& apt-get install -y --no-install-recommends $(PKGS) \
	&& rm -rf /var/lib/apt/lists/*
