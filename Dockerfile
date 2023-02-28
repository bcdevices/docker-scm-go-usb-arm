ARG	GOLANG_VERSION=1.20.1
FROM	golang:${GOLANG_VERSION}-bullseye
ARG	PKGS
ENV	PKGS="$(PKGS) zip"
ENV	PKGS="$(PKGS)"
ENV	PKGS="$(PKGS) unzip"
ENV	PKGS="$(PKGS) libusb-1.0-0-dev"
ENV	PKGS="$(PKGS) crossbuild-essential-arm64"
ENV	PKGS="$(PKGS) libusb-1.0-0-dev:arm64"
ENV	PKGS="$(PKGS) crossbuild-essential-armhf"
ENV	PKGS="$(PKGS) libusb-1.0-0-dev:armhf"

# hadolint ignore=DL3008,SC2046
RUN	apt-get update \
	&& dpkg --add-architecture arm64 \
	&& dpkg --add-architecture armhf \
	&& apt-get install -y --no-install-recommends $(PKGS) \
	&& rm -rf /var/lib/apt/lists/*
