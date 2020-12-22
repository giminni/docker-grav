#!/usr/bin/env bash

declare STAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${STAGE_DIR}/runlet-head.sh"
# DO NOT REMOVE ANYTHING BEFORE THIS LINE!

echo "Setting ownership to www-data..."
chown -R www-data:www-data /var/www/
echo "Setting composer link..."
ln -s /var/www/html/bin/composer-phar /var/www/html/bin/composer
echo "Creating run directory for SSH daemon..."
mkdir -vp /run/sshd
echo "Downloading su-exec..."
test -f /tmp/${GRAV_SUEXEC_FILE} || wget --progress=bar:force \
    -O /tmp/${GRAV_SUEXEC_FILE} \
${GRAV_SUEXEC_URL}/${GRAV_SUEXEC_FILE}
echo "Compiling su-exec..."
gcc -Wall /tmp/${GRAV_SUEXEC_FILE} -o /usr/local/bin/su-exec
echo "Uploading compiled files to global cache repository"
rsync -avz -e "ssh -i /home/${GRAV_USER}/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
   ${CCACHE_DIR} ${CACHE_USER}@${CACHE_HOST}:${CACHE_DIR}

# DO NOT REMOVE ANYTHING BELOW THIS LINE!
source "${STAGE_DIR}/runlet-tail.sh"