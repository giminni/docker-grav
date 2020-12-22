#!/usr/bin/env bash

declare STAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${STAGE_DIR}/runlet-head.sh"
# DO NOT REMOVE ANYTHING BEFORE THIS LINE!

echo "Setting recommended PHP.ini values..."
{ \
echo 'opcache.memory_consumption=128'; \
echo 'opcache.interned_strings_buffer=8'; \
echo 'opcache.max_accelerated_files=4000'; \
echo 'opcache.revalidate_freq=2'; \
echo 'opcache.fast_shutdown=1'; \
echo 'opcache.enable_cli=1'; \
echo 'upload_max_filesize=128M'; \
echo 'post_max_size=128M'; \
echo 'expose_php=off'; \
echo ''; \
echo '[XDebug]'; \
echo 'xdebug.remote_enable=1'; \
echo 'xdebug.remote_autostart=1'; \
} > /usr/local/etc/php/conf.d/php-recommended.ini

# DO NOT REMOVE ANYTHING BELOW THIS LINE!
source "${STAGE_DIR}/runlet-tail.sh"