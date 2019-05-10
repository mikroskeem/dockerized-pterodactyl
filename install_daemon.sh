#!/bin/sh -e

# Install base dependencies
apk update
apk upgrade

# Line 1: base
# Line 2: Node.js and Yarn
# Line 3: required for Pterodactyl daemon building
apk add \
    tzdata \
    nodejs yarn \
    curl unzip make gcc g++ python tar

# Set up timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Install Pterodactyl daemon
mkdir -p /srv/daemon /srv/daemon-data \
    && cd /srv/daemon \
    && curl -s -L "https://github.com/pterodactyl/daemon/releases/download/${PTERODACTYL_RELEASE}/daemon.tar.gz" | tar --strip-components=1 -xzf - \
    && rm package-lock.json \
    && yarn install --production

# Clean up
apk del make gcc g++ python tar
