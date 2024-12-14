# scm-go-usb-lint: Alpine-based reviewdog-golangci image with libusb support.
ARG GOLANG_VERSION="1.23.4"
FROM golang:${GOLANG_VERSION}-alpine
ARG GOLANGCI_LINT_VERSION="1.51.2"
ARG REVIEWDOG_VERSION="0.14.1"
ARG PKGS
RUN apk add \
	build-base \
	curl \
	git \
	libusb-dev \
	pkgconfig \
	${PKGS} \
	&& rm -rf /var/cache/apk/* \
        && curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh    | sh -s -- -b $(go env GOPATH)/bin "v${REVIEWDOG_VERSION}" \
        && curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin "v${GOLANGCI_LINT_VERSION}"
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
