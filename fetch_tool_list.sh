#!/usr/bin/env bash
docker run -v $PWD:/opt/mount --rm --user "$(id -u):$(id -g)" --entrypoint cp "$1" /etc/irida/tool-list.yml /opt/mount/tool-list.yml