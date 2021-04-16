#!/bin/sh

docker run -it \
           -e CRYPTOSTAT_TEST \
           -e CRYPTOSTAT_DEBUG \
           -v "$(/bin/pwd)/config:/dist/config" \
           cryptostat:latest
