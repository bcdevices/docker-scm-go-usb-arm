FROM buildpack-deps:stretch-scm

# Setup environment
ENV DEBIAN_FRONTEND noninteractive
ENV TERM=xterm

# Setup locale
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends locales \
  && rm -rf /var/lib/apt/lists/*
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
  && dpkg-reconfigure --frontend=noninteractive locales \
  && update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV LANG=C.UTF-8

# Install needed packages
RUN apt-get update && apt-get install -y --no-install-recommends \
		crossbuild-essential-armhf \
		g++ \
		gcc \
		git \
		libusb-1.0-0-dev \
		make \
		pkg-config \
		unzip \
		zip \
	  && rm -rf /var/lib/apt/lists/*

RUN dpkg --add-architecture armhf \
  && apt-get update \
  && apt-get -y install --no-install-recommends libusb-1.0-0-dev:armhf \
  && rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.12.4
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 d7d1f1f88ddfe55840712dc1747f37a790cbcaa448f6c9cf51bbe10aa65442f5

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
  && echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
  && tar -C /usr/local -xzf golang.tar.gz \
  && rm golang.tar.gz

ENV GOPATH /go

ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
