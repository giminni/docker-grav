#!/usr/bin/env bash
set -euo pipefail

GRAV_BACK="${1:-""}"
GRAV_FILE="${GRAV_BACK##*/}"
GRAV_ROOT="/var/www"
GRAV_HOME="${GRAV_ROOT}/grav-admin"

find "${GRAV_HOME}" -xdev -depth -mindepth 1 -exec rm -Rf {} \;


if [ ! -e ${GRAV_ROOT}/${GRAV_FILE}.zip ]; then
   scp "${GRAV_BACK}" "${GRAV_ROOT}"
fi

cd "${GRAV_HOME}"
unzip ../"${GRAV_FILE}".zip
find ./ -type d -exec chmod 750 {} \;
find ./ -type f -exec chmod 660 {} \;
chmod +x "${GRAV_HOME}"/bin/*
