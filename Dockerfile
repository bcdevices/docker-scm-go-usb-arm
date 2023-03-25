# scm-go-usb
ARG BUILDPACK_HOSTOS="jammy"
FROM buildpack-deps:${BUILDPACK_HOSTOS}-scm

ENV GOLANG_VERSION="1.20.1"

# hadolint ignore=DL3008
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	; \
	rm -rf /var/lib/apt/lists/*

ENV PATH /usr/local/go/bin:$PATH

# hadolint ignore=DL3003,DL3008,DL3047,DL4006,SC2086
RUN set -eux; \
	arch="$(dpkg --print-architecture)"; arch="${arch##*-}"; \
	url=; \
	case "$arch" in \
		'amd64') \
			url='https://dl.google.com/go/go1.20.1.linux-amd64.tar.gz'; \
			sha256='000a5b1fca4f75895f78befeb2eecf10bfff3c428597f3f1e69133b63b911b02'; \
			;; \
		'armhf') \
			url='https://dl.google.com/go/go1.20.1.linux-armv6l.tar.gz'; \
			sha256='e4edc05558ab3657ba3dddb909209463cee38df9c1996893dd08cde274915003'; \
			;; \
		'arm64') \
			url='https://dl.google.com/go/go1.20.1.linux-arm64.tar.gz'; \
			sha256='5e5e2926733595e6f3c5b5ad1089afac11c1490351855e87849d0e7702b1ec2e'; \
			;; \
		*) echo >&2 "error: unsupported architecture '$arch' (likely packaging update needed)"; exit 1 ;; \
	esac; \
	wget -O go.tgz.asc "$url.asc"; \
	wget -O go.tgz "$url" --progress=dot:giga; \
	echo "$sha256 *go.tgz" | sha256sum -c -; \
	\
	GNUPGHOME="$(mktemp -d)"; export GNUPGHOME; \
	gpg --batch --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 'EB4C 1BFD 4F04 2F6D DDCC  EC91 7721 F63B D38B 4796'; \
	gpg --batch --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys '2F52 8D36 D67B 69ED F998  D857 78BD 6547 3CB3 BD13'; \
	gpg --batch --verify go.tgz.asc go.tgz; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME" go.tgz.asc; \
	\
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	\
	\
	go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH

ENV PKGS=""
ENV PKGS="${PKGS} crossbuild-essential-amd64"
ENV PKGS="${PKGS} libusb-1.0-0-dev:amd64"
ENV PKGS="${PKGS} crossbuild-essential-arm64"
ENV PKGS="${PKGS} libusb-1.0-0-dev:arm64"
ENV PKGS="${PKGS} crossbuild-essential-armhf"
ENV PKGS="${PKGS} libusb-1.0-0-dev:armhf"
ENV PKGS="${PKGS} libusb-1.0-0-dev"
ENV PKGS="${PKGS} zip"

# DL3008: `apt-get install <package>=<version>` (intentional)
# hadolint ignore=DL3008,SC2028
RUN set -eux; \
	echo "deb [arch=amd64] http://archive.ubuntu.com/ubuntu jammy main restricted universe multiverse\n\
deb [arch=amd64] http://security.ubuntu.com/ubuntu jammy-updates main restricted universe multiverse\n\
deb [arch=amd64] http://security.ubuntu.com/ubuntu jammy-security main restricted universe multiverse\n\
deb [arch=amd64] http://archive.ubuntu.com/ubuntu jammy-backports main restricted universe multiverse\n\
deb [arch=arm64,armhf] http://ports.ubuntu.com/ jammy main restricted universe multiverse\n\
deb [arch=arm64,armhf] http://ports.ubuntu.com/ jammy-updates main restricted universe multiverse\n\
deb [arch=arm64,armhf] http://ports.ubuntu.com/ jammy-security main restricted universe multiverse\n\
deb [arch=arm64,armhf] http://ports.ubuntu.com/ jammy-backports main restricted universe multiverse" > /etc/apt/sources.list; \
	dpkg --add-architecture "amd64"; \
	dpkg --add-architecture "arm64"; \
	dpkg --add-architecture "armhf"; \
	apt-get update; \
	apt-get -y install --no-install-recommends ${PKGS}; \
	rm -rf /var/lib/apt/lists/*
