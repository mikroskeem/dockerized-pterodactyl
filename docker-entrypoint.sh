#!/bin/sh

SFTP_PIDFILE="/tmp/sftp-server.pid"

if [ "${*}" = "yarn start" ]; then
    if [ ! -f "/srv/daemon/config/core.json" ]; then
        echo ">>> ERROR: configuration is not present"
        exit 1
    fi

    # Start SFTP server
    /srv/daemon/sftp-server &
    echo "${!}" > "${SFTP_PIDFILE}"

    yarn start

    # Stop SFTP server
    if [ -f "${SFTP_PIDFILE}" ] && (kill -0 "$(cat "${SFTP_PIDFILE}")"); then
        kill -15 "$(cat "${SFTP_PIDFILE}")"
    fi
else
    exec "${@}"
fi
