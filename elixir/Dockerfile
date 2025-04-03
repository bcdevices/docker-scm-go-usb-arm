# nsb-elixir-go: Nerves-based system build image with Elixir and Go.
ARG NERVES_SYSTEM_BR_VERSION="1.20.6"
FROM nervesproject/nerves_system_br:${NERVES_SYSTEM_BR_VERSION}
ARG ELIXIR_VERSION="1.14.1-otp-25"
ARG GOLANG_VERSION="1.24.1"
ARG GOLANG_DOWNLOAD_SHA256_amd64="6924efde5de86fe277676e929dc9917d466efa02fb934197bc2eba35d5680971"
ARG GOLANG_DOWNLOAD_SHA256_arm64="16e5017863a7f6071363782b1b8042eb12c6ca4f4cd71528b2123f0a1275b13e"
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
