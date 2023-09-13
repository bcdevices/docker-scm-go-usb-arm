# nsb-elixir-go: Nerves-based system build image with Elixir and Go.
ARG NERVES_SYSTEM_BR_VERSION="1.20.6"
FROM nervesproject/nerves_system_br:${NERVES_SYSTEM_BR_VERSION}
ARG ELIXIR_VERSION="1.14.1-otp-25"
ARG GOLANG_VERSION="1.21.1"
ARG GOLANG_DOWNLOAD_SHA256_amd64="000a5b1fca4f75895f78befeb2eecf10bfff3c428597f3f1e69133b63b911b02"
ARG GOLANG_DOWNLOAD_SHA256_arm64="5e5e2926733595e6f3c5b5ad1089afac11c1490351855e87849d0e7702b1ec2e"
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
