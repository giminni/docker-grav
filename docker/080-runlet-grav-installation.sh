#!/usr/bin/env bash

declare STAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${STAGE_DIR}/runlet-head.sh"
# DO NOT REMOVE ANYTHING BEFORE THIS LINE!

echo "Installing ${GRAV_URLFILE}...";
test -f "/tmp/grav/${GRAV_KIND}/${GRAV_URLFILE}" || wget -q --show-progress --progress=bar:force \
    -O "/tmp/grav/${GRAV_KIND}/${GRAV_URLFILE}" \
    ${GRAV_URL}
cd /var/www
rm -rf /var/www/html
unzip "/tmp/grav/${GRAV_KIND}/${GRAV_URLFILE}"
echo "Creating symlink for URL access..."
ln -s /var/www/${GRAV_NAME} /var/www/html
echo "Exporting ${GRAV_NAME} path to users..."
echo "export PATH=/var/www/html/bin:${PATH}" >> /home/${GRAV_USER}/.bashrc
echo "export PATH=/var/www/html/bin:${PATH}" >> /root/.bashrc

# DO NOT REMOVE ANYTHING BELOW THIS LINE!
source "${STAGE_DIR}/runlet-tail.sh"