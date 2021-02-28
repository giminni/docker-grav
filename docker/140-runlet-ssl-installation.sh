#!/usr/bin/env bash

declare STAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${STAGE_DIR}/runlet-head.sh"
# DO NOT REMOVE ANYTHING BEFORE THIS LINE!

echo "Downloading and installing getssl package..."
test -f /tmp/getssl || wget -qO - --show-progress --progress=bar:force \
${GETSSL_URL}/v${GETSSL_VER}.tar.gz | \
   sudo tar xvzf - --strip=1 -C /usr/local/bin getssl-${GETSSL_VER}/getssl
chmod +x /usr/local/bin/getssl

# DO NOT REMOVE ANYTHING BELOW THIS LINE!
source "${STAGE_DIR}/runlet-tail.sh"
