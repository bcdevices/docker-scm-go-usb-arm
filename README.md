# scm-go-usb-arm

Docker image with:
- golang
- libusb-1.0-0-dev

Target platforms:
- Host: container image platform (Linux/AArch64, Linux/x86\_64)
- `linux/amd64`: Linux/x86\_64
- `linux/arm64`: Linux/AArch64
- `linux/armhf`: Linux/armv7+

## Including additional packages

Additional packages can be included, by building the Docker image
an `$PKGS` build argument.

For example, to add *libftdi1*:

```
docker build \
  --build-arg PKGS="libftdi1-dev libftdi1-dev:amd64 libftdi1-dev:arm64 libftdi1-dev:armhf" \
  ...
```
