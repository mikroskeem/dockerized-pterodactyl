#!/bin/bash -e

# Based on nodesource install script
export DEBIAN_FRONTEND=noninteractive

# Install base dependencies
apt-get update
apt-get upgrade -y

# Line 1: base
# Line 2: required for node.js/yarn installation
# Line 3: required for Pterodactyl daemon building
apt-get install -y \
    locales tzdata \
    apt-transport-https apt-utils lsb-release curl \
    gnupg unzip make gcc g++ python

# Set up locale and timezone
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Set up and install Node.js and Yarn
curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -

cat > /etc/apt/sources.list.d/nodesource.list <<EOF
deb https://deb.nodesource.com/${NODEREPO} ${DISTRO} main
deb-src https://deb.nodesource.com/${NODEREPO} ${DISTRO} main
EOF

echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list

# Install node.js and yarn
apt-get update
apt-get install -y nodejs yarn

# Install Pterodactyl daemon
mkdir -p /srv/daemon /srv/daemon-data \
    && cd /srv/daemon \
    && curl -s -L "https://github.com/pterodactyl/daemon/releases/download/${PTERODACTYL_RELEASE}/daemon.tar.gz" | tar --strip-components=1 -xzf - \
    && rm package-lock.json \
    && yarn install --production

# Clean up
apt-get remove -y apt-utils make gcc g++ python
apt-get autoremove -y
rm -rf /var/lib/apt/lists/*
