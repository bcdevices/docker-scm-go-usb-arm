#!/bin/bash

git config --global --add safe.directory "$PWD"

VERBOSE=y make distclean test
TARGET_ARCH=linux-arm64 VERBOSE=y make
TARGET_ARCH=linux-amd64 VERBOSE=y make
VERBOSE=y make dist-archive
