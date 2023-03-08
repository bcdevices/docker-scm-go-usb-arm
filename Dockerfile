ARG	GOLANG_VERSION="1.20.1"
FROM	golang:${GOLANG_VERSION}-jammy
ARG	PKGS
# hadolint ignore=DL3008,SC2046
RUN	dpkg --add-architecture amd64 \
	&& dpkg --add-architecture arm64 \
	&& dpkg --add-architecture armhf \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		crossbuild-essential-amd64 \
		crossbuild-essential-arm64 \
		crossbuild-essential-armhf \
		libusb-1.0-0-dev \
		libusb-1.0-0-dev:amd64 \
		libusb-1.0-0-dev:arm64 \
		libusb-1.0-0-dev:armhf \
		unzip \
		zip \
		${PKGS} \
	&& rm -rf /var/lib/apt/lists/*
