#!/usr/bin/env bash

declare STAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${STAGE_DIR}/runlet-head.sh"
# DO NOT REMOVE ANYTHING BEFORE THIS LINE!

echo "Downloading dehydrated ${DEHYDRATED_VER} package..."
test -f /tmp/${DEHYDRATED_FILE} || wget -q --show-progress --progress=bar:force \
     -O /tmp/dehydrated.tgz \
${DEHYDRATED_URL}/v${DEHYDRATED_VER}/dehydrated-${DEHYDRATED_VER}.tar.gz
tar -xvzf /tmp/dehydrated.tgz -C /tmp
cp /tmp/dehydrated-${DEHYDRATED_VER}/dehydrated /usr/local/bin

# DO NOT REMOVE ANYTHING BELOW THIS LINE!
source "${STAGE_DIR}/runlet-tail.sh"