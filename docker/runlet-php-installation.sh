#!/usr/bin/env bash

declare STAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${STAGE_DIR}/runlet-head.sh"
# DO NOT REMOVE ANYTHING BEFORE THIS LINE!

echo "Installing PHP extensions..."
pear config-set cache_dir /tmp/cache/.phpcache/cache
pear config-set download_dir /tmp/cache/.phpcache/download
pear config-set php_ini /usr/local/etc/php/conf.d/php-recommended.ini
docker-php-ext-install opcache pdo pdo_mysql pdo_pgsql pgsql
docker-php-ext-configure intl
docker-php-ext-install intl
docker-php-ext-configure gd --with-freetype --with-jpeg
docker-php-ext-install -j$(nproc) gd
docker-php-ext-install zip
pecl install apcu yaml-2.0.4
docker-php-ext-enable apcu yaml
pecl install xdebug
echo "Uploading compiled C/C++ files to global cache repository"
rsync -avz -e "ssh -i /home/${GRAV_USER}/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
   ${CCACHE_DIR} ${CACHE_USER}@${CACHE_HOST}:${CACHE_DIR}
echo "Uploading compiled PHP files to global cache repository"
rsync -avz -e "ssh -i /home/${GRAV_USER}/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
   ${PHPCACHE_DIR} ${CACHE_USER}@${CACHE_HOST}:${CACHE_DIR}

# DO NOT REMOVE ANYTHING BELOW THIS LINE!
source "${STAGE_DIR}/runlet-tail.sh"