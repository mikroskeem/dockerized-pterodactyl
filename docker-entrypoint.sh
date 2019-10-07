#!/bin/sh

SFTP_PIDFILE="/tmp/sftp-server.pid"
SOCAT_PIDFILE="/tmp/docker-socat.pid"

do_kill () {
    pidfile="${1}"
    pid=""
    if [ -f "${pidfile}" ]; then
        pid="$(cat "${pidfile}")"
    fi

    if [ -n "${pid}" ] && (kill -0 "${pid}" >/dev/null); then
        kill -15 "${pid}"
    fi
}

if [ "${*}" = "yarn start" ]; then
    if [ ! -f "/srv/daemon/config/core.json" ]; then
        echo ">>> ERROR: configuration is not present"
        exit 1
    fi

    # Set up Docker socket bridge
    setup_bridge=0
    if [ -f /var/run/docker.sock ]; then
        # TODO: test connection first
        rm /var/run/docker.sock
        setup_bridge=1
    fi

    # Set up Docker socket bridge
    if [ "${setup_bridge}" = "1" ]; then
        if [ -z "${DOCKER_TCP_DEST}" ]; then
            echo ">>> Environment variable 'DOCKER_TCP_DEST' is not set"
            exit 1
        fi
        socat unix-listen:/var/run/docker.sock,fork tcp:"${DOCKER_TCP_DEST}" &
        echo "${!}" > "${SOCAT_PIDFILE}"
    fi

    # Start SFTP server
    /srv/daemon/sftp-server &
    echo "${!}" > "${SFTP_PIDFILE}"

    yarn start

    # Stop Docker socket bridge and SFTP daemon
    do_kill "${SOCAT_PIDFILE}"
    do_kill "${SFTP_PIDFILE}"
else
    exec "${@}"
fi
