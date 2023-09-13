# scm-go-usb-build

ARG GOLANG_VERSION="1.21.1"
ARG GOUSB_HOSTOS="jammy"
ARG GOUSB_VERSION="2"
FROM ghcr.io/bcdevices/scm-go-usb-arm:v${GOLANG_VERSION}-${GOUSB_HOSTOS}-${GOUSB_VERSION}

#Create Work Directory
RUN mkdir -p /app

#Set Working Directory
WORKDIR /app

COPY . /app

# DL3020 error: Use COPY instead of ADD for files and folders
# hadolint ignore=DL3020
ADD entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]
