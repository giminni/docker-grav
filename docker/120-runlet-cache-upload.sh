#!/usr/bin/env bash

declare STAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${STAGE_DIR}/runlet-head.sh"
# DO NOT REMOVE ANYTHING BEFORE THIS LINE!

echo "Uploading compiled C/C++ files to global cache repository"
rsync -avz -e "ssh -i /home/${GRAV_USER}/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
   ${CCACHE_DIR} ${CACHE_USER}@${CACHE_HOST}:${CACHE_DIR}
echo "Uploading compiled PHP files to global cache repository"
rsync -avz -e "ssh -i /home/${GRAV_USER}/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
   ${PHPCACHE_DIR} ${CACHE_USER}@${CACHE_HOST}:${CACHE_DIR}

# DO NOT REMOVE ANYTHING BELOW THIS LINE!
source "${STAGE_DIR}/runlet-tail.sh"