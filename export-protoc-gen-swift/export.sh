#!/usr/bin/env bash
docker run --rm -i -v`pwd`:/export `docker build -q .` $@
