#!/usr/bin/env bash

declare STAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${STAGE_DIR}/runlet-head.sh"
# DO NOT REMOVE ANYTHING BEFORE THIS LINE!

echo "Downloading getssl package..."
test -f /tmp/getssl || wget -q --show-progress --progress=bar:force \
     -O /usr/local/bin/getssl \
https://raw.githubusercontent.com/srvrco/getssl/master/getssl
chmod +x /usr/local/bin/getssl

# DO NOT REMOVE ANYTHING BELOW THIS LINE!
source "${STAGE_DIR}/runlet-tail.sh"