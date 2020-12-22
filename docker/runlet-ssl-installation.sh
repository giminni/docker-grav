#!/usr/bin/env bash

declare STAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${STAGE_DIR}/runlet-head.sh"
# DO NOT REMOVE ANYTHING BEFORE THIS LINE!

echo "Downloading dehydrated ${DEHYDRATED_VER} package..."
wget --progress=bar:force -O /tmp/dehydrated.tgz \
     https://github.com/dehydrated-io/dehydrated/releases/download/v${DEHYDRATED_VER}/dehydrated-${DEHYDRATED_VER}.tar.gz
tar -xvzf /tmp/dehydrated.tgz -C /tmp
cp /tmp/dehydrated-${DEHYDRATED_VER}/dehydrated /usr/local/bin

# DO NOT REMOVE ANYTHING BELOW THIS LINE!
source "${STAGE_DIR}/runlet-tail.sh"