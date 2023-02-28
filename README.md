# scm-go-usb-arm

Docker image for Go cross-compilation with libusb support.

Target platforms:
- Host: container image platform (Linux/AArch64, Linux/x86\_64)
- `linux/amd64`: Linux/x86\_64
- `linux/arm64`: Linux/AArch64
- `linux/armhf`: Linux/armv7+

## Including additional packages

Additional packages can be included, by building the Docker image
with a `PKGS` build argument.

```Shell
# Include libzmq3-dev, for all supported targets
docker build \
  --build-arg PKGS="libzmq3-dev libzmq3-dev:amd64 libzmq3-dev:arm64 libzmq3-dev:armhf" \
  .
```

```Shell
# Include libftdi1-dev, for linux/arm64 only
docker build \
  --build-arg PKGS="libftdi1-dev:arm64" \
  .
```
