# nsb-elixir-go: Nerves-based system build image with Elixir and Go.
ARG NERVES_SYSTEM_BR_VERSION="1.20.6"
FROM nervesproject/nerves_system_br:${NERVES_SYSTEM_BR_VERSION}
ARG ELIXIR_VERSION="1.14.1-otp-25"
ARG GOLANG_VERSION="1.25.8"

ARG GOLANG_DOWNLOAD_SHA256_amd64="ceb5e041bbc3893846bd1614d76cb4681c91dadee579426cf21a63f2d7e03be6"
ARG GOLANG_DOWNLOAD_SHA256_arm64="7d137f59f66bb93f40a6b2b11e713adc2a9d0c8d9ae581718e3fad19e5295dc7"
# Container host platform, set automatically by `docker build`
ARG TARGETPLATFORM="linux/amd64"

RUN bash -c 'set -euxo pipefail \
	&& URL="https://repo.hex.pm/builds/elixir/v${ELIXIR_VERSION}.zip" \
	&& wget --progress=dot:giga "${URL}" \
	&& unzip -d "/usr/local/elixir" "v${ELIXIR_VERSION}.zip" \
	&& rm "v${ELIXIR_VERSION}.zip" \
	&& case "${TARGETPLATFORM}" in \
	linux/arm64) ARCH=arm64; SHA256="${GOLANG_DOWNLOAD_SHA256_arm64}" ;; \
	linux/amd64|*) ARCH=amd64; SHA256="${GOLANG_DOWNLOAD_SHA256_amd64}" ;; \
	esac \
	&& URL="https://golang.org/dl/go${GOLANG_VERSION}.linux-${ARCH}.tar.gz" \
	&& curl -fsSL --http1.1 "${URL}" -o golang.tar.gz \
	&& echo "${SHA256}  golang.tar.gz" | sha256sum -c - \
	&& tar -C /usr/local -xzf golang.tar.gz \
	&& rm golang.tar.gz'

ENV GOPATH="/go"
ENV PATH="/usr/local/go/bin:/usr/local/elixir/bin:${PATH}"
