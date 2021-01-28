#!/usr/bin/env bash

declare STAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${STAGE_DIR}/runlet-head.sh"
# DO NOT REMOVE ANYTHING BEFORE THIS LINE!

echo "Setting apache modules and rewrites..."
a2enmod rewrite expires
if [ "${OSTYPE:0:6}" == "darwin" ]; then
   sed -i '' 's/ServerTokens OS/ServerTokens ProductOnly/g' \
        /etc/apache2/conf-available/security.conf
else
   sed -i 's/ServerTokens OS/ServerTokens ProductOnly/g' \
        /etc/apache2/conf-available/security.conf
fi

# DO NOT REMOVE ANYTHING BELOW THIS LINE!
source "${STAGE_DIR}/runlet-tail.sh"
