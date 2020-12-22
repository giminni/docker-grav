#!/usr/bin/env bash

declare STAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${STAGE_DIR}/runlet-head.sh"
# DO NOT REMOVE ANYTHING BEFORE THIS LINE!

echo "Setting timezone to ${TZ}..."
ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime

# DO NOT REMOVE ANYTHING BELOW THIS LINE!
source "${STAGE_DIR}/runlet-tail.sh"