#!/bin/bash -e

# Based on nodesource install script
export DEBIAN_FRONTEND=noninteractive

# Install base dependencies
apt-get update
apt-get upgrade -y

# Line 1: base
# Line 2: required for node.js/yarn/docker installation
# Line 3: required for Pterodactyl daemon building
# Line 4: required for workarounds
apt-get install -y \
    locales tzdata \
    apt-transport-https apt-utils lsb-release curl gnupg-agent ca-certificates software-properties-common \
    gnupg unzip make gcc g++ python \
    socat

# Set up locale and timezone
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Set up and install Docker, Node.js and Yarn
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -

echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu ${DISTRO} stable" > /etc/apt/sources.list.d/docker.list
echo "deb https://deb.nodesource.com/${NODEREPO} ${DISTRO} main" > /etc/apt/sources.list.d/nodesource.list
echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list

# Install docker, node.js and yarn
apt-get update
apt-get install -y docker-ce-cli nodejs yarn

# Set up pterodactyl user and group
groupadd --system -g 999 pterodactyl
useradd --system -u 999 -g 999 -s /bin/false -d / pterodactyl

# Install Pterodactyl daemon
mkdir -p /srv/daemon /srv/daemon-data \
    && cd /srv/daemon \
    && curl -s -L "https://github.com/pterodactyl/daemon/releases/download/${PTERODACTYL_RELEASE}/daemon.tar.gz" | tar --strip-components=1 -xzf - \
    && curl -Lo sftp-server "https://github.com/pterodactyl/sftp-server/releases/download/${PTERODACTYL_SFTP_RELEASE}/sftp-server" \
    && chmod +x sftp-server \
    && rm package-lock.json \
    && yarn install --production

# Clean up
apt-get remove -y apt-utils make gcc g++ python
apt-get autoremove -y
rm -rf /var/lib/apt/lists/*
