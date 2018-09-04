#!/usr/bin/env bash

VER=1.13.6.2

docker run --rm -v $(pwd)/debian/$VER:/src -v $(pwd)/build:/build debian:stretch /src/build_plugin.sh
