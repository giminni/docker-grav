#!/bin/bash
set -euo pipefail

declare _RC=0

declare _GRAV_CMD="${1:-"init"}"

case "${_GRAV_CMD}" in
"init") /usr/sbin/sshd && cron && apache2-foreground; ;;
"bash") bash; ;;
     *) exec "$@"; ;;
esac

exit ${_RC}