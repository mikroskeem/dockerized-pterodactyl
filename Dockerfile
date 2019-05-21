FROM ubuntu:18.04
LABEL maintainer="Mark Vainomaa <mikroskeem@mikroskeem.eu>"

# Install base system
COPY install_daemon.sh /
RUN \
    NODEREPO=node_10.x \
    DISTRO=bionic \
    PTERODACTYL_RELEASE=v0.6.12 \
    PTERODACTYL_SFTP_RELEASE=v1.0.4 \
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
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["yarn", "start"]
