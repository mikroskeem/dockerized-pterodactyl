FROM alpine:3.9.3
LABEL maintainer="Mark Vainomaa <mikroskeem@mikroskeem.eu>"

# Install base system
COPY install_daemon.sh /
RUN \
    PTERODACTYL_RELEASE=v0.6.12 \
    /install_daemon.sh && rm /install_daemon.sh

# Expose volumes
VOLUME /srv/daemon/config
VOLUME /srv/daemon/packs
VOLUME /srv/daemon-data
VOLUME /tmp/pterodactyl
VOLUME /var/lib/docker/containers
VOLUME /var/lib/docker.sock

# Expose ports
EXPOSE 80/tcp
EXPOSE 2022/tcp

# Default entry point
WORKDIR /srv/daemon
CMD ["yarn", "start"]
