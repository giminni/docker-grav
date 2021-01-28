#!/usr/bin/env bash

declare STAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${STAGE_DIR}/runlet-head.sh"
# DO NOT REMOVE ANYTHING BEFORE THIS LINE!

echo "Configuring Ccache tool..."
/usr/sbin/update-ccache-symlinks
for PROG in $(ls /usr/lib/ccache); do ln -s $(which ccache) /usr/local/bin/${PROG}; done

echo "Downloading cached C/C++ packages from global cache repository..."
rsync -avz -e "ssh -i /home/${GRAV_USER}/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
      ${CACHE_USER}@${CACHE_HOST}:${CACHE_DIR}/.ccache ${CCACHE_DIR%/*}
echo "Downloading cached PHP packages from global cache repository..."
rsync -avz -e "ssh -i /home/${GRAV_USER}/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
      ${CACHE_USER}@${CACHE_HOST}:${CACHE_DIR}/.phpcache ${PHPCACHE_DIR%/*}

# DO NOT REMOVE ANYTHING BELOW THIS LINE!
source "${STAGE_DIR}/runlet-tail.sh"