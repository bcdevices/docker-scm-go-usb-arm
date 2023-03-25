#!/bin/bash

git config --global --add safe.directory "$PWD"

VERBOSE=y make distclean dist test
