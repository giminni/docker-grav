#!/usr/bin/env bash

set -euo pipefail

declare _RC=0

declare _GRAV_CMD="${1:-"init"}"
declare _GRAV_USER="${2:-"grav"}"

if [ "${_GRAV_CMD}" == "debug" ]; then set -x; fi      

if [ $(pgrep dropbear | wc -l ) -ge 1 ]; then 
     kill -9 $(pidof dropbear) 
fi

case "${_GRAV_CMD}" in
   "init"|"debug")
      su-exec "${_GRAV_USER}" dropbear -R -w -g -s -a
      su-exec "${_GRAV_USER}" gocrond --allow-unprivileged --default-user="${_GRAV_USER}" grav:/home/"${_GRAV_USER}"/crontab 1>/tmp/gocrond.log 2>&1 &
      # Last entry must be apache2 in foreground mode
      su-exec "${_GRAV_USER}" apache2-foreground 
      ;;

   "bash") bash; ;;

   *) exec "$@"; ;;
esac

exit ${_RC}
